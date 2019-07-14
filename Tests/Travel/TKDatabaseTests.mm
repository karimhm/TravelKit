/*
 *  TKDatabaseTests.m
 *  Created on 17/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <XCTest/XCTest.h>
#import <dispatch/semaphore.h>
#import <CoreLocation/CLLocation.h>
#import "TKDBTestCase.h"
#import "TKDatabase.h"

@interface TKDatabaseTests : TKDBTestCase

@property (strong, nonatomic) TKDatabase *database;

@end

@implementation TKDatabaseTests : TKDBTestCase

- (void)setUp {
    [super setUp];
    
    int status = SQLITE_OK;
    
    status = sqlite3_exec(self.sqliteDB, "\
                          CREATE TABLE IF NOT EXISTS StopPlace (\
                              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,\
                              nameId INTEGER REFERENCES Localization(id) NOT NULL,\
                              latitude DOUBLE NOT NULL,\
                              longitude DOUBLE NOT NULL\
                          );\
                          CREATE TABLE Properties (\
                              id TEXT,\
                              value BLOB\
                          );\
                          CREATE TABLE IF NOT EXISTS Localization (\
                              id INTEGER NOT NULL,\
                              language TEXT NOT NULL,\
                              text TEXT NOT NULL\
                          );\
                          CREATE TABLE IF NOT EXISTS Route (\
                              id INTEGER PRIMARY KEY NOT NULL,\
                              nameId INTEGER REFERENCES Localization(id),\
                              descriptionId INTEGER REFERENCES Localization(id),\
                              color INT\
                          );\
                          CREATE TABLE IF NOT EXISTS Calendar (\
                              id INTEGER PRIMARY KEY NOT NULL,\
                              nameId INTEGER REFERENCES Localization(id),\
                              shortNameId INTEGER REFERENCES Localization(id),\
                              days INT CHECK (days <= 127) NOT NULL\
                          );\
                          CREATE TABLE IF NOT EXISTS Trip (\
                              id INTEGER PRIMARY KEY NOT NULL,\
                              calendarId INTEGER REFERENCES Calendar(id) NOT NULL,\
                              routeId INTEGER REFERENCES Route(id) NOT NULL\
                          );\
                          CREATE TABLE IF NOT EXISTS RoutePattern (\
                              id INTEGER PRIMARY KEY NOT NULL,\
                              routeId INTEGER REFERENCES Route(id) NOT NULL,\
                              stopPlaceId INTEGER REFERENCES StopPlace(id) NOT NULL,\
                              direction INT CHECK (direction = 1 OR direction = 2),\
                              position INT CHECK (position <= 65535) NOT NULL\
                          );\
                          ", nullptr, nullptr, nullptr);
    
    XCTAssertTrue(status == SQLITE_OK, "Unable to create stop places table");
    
    status = sqlite3_exec(self.sqliteDB, "\
                          INSERT INTO Localization(id, language, text) VALUES(1, 'en', 'testPlace1');\
                          INSERT INTO Localization(id, language, text) VALUES(2, 'en', 'testPlace2');\
                          INSERT INTO Localization(id, language, text) VALUES(3, 'en', 'testPlaceA1');\
                          INSERT INTO Localization(id, language, text) VALUES(4, 'en', 'testPlaceA2');\
                          INSERT INTO Localization(id, language, text) VALUES(5, 'en', 'testPlaceA3');\
                          INSERT INTO Localization(id, language, text) VALUES(6, 'en', 'testRoute1');\
                          INSERT INTO Localization(id, language, text) VALUES(13, 'en', 'testRoute1 Description');\
                          INSERT INTO Localization(id, language, text) VALUES(7, 'en', 'testCalendar1');\
                          INSERT INTO Localization(id, language, text) VALUES(8, 'en', 'testCalendar2');\
                          INSERT INTO Localization(id, language, text) VALUES(9, 'en', 'testCalendar3');\
                          INSERT INTO Localization(id, language, text) VALUES(10, 'en', 'testCalendar1 ShortName');\
                          INSERT INTO Localization(id, language, text) VALUES(11, 'en', 'testCalendar2 ShortName');\
                          INSERT INTO Localization(id, language, text) VALUES(12, 'en', 'testCalendar3 ShortName');\
                          \
                          INSERT INTO Localization(id, language, text) VALUES(1, 'ar', 'testPlace1-ar');\
                          \
                          INSERT INTO Route(id, nameId, descriptionId, color) VALUES(1, 6, 13, 16777215);\
                          \
                          INSERT INTO StopPlace(id, nameId, latitude, longitude) VALUES(1, 1 , 0, 0);\
                          INSERT INTO StopPlace(id, nameId, latitude, longitude) VALUES(2, 2 , 1, 0);\
                          INSERT INTO StopPlace(id, nameId, latitude, longitude) VALUES(3, 3 , 2, 0);\
                          INSERT INTO StopPlace(id, nameId, latitude, longitude) VALUES(4, 4 , 3, 0);\
                          INSERT INTO StopPlace(id, nameId, latitude, longitude) VALUES(5, 5 , 4, 0);\
                          \
                          INSERT INTO Properties(id, value) VALUES('testProperty1', 'testProperty');\
                          INSERT INTO Properties(id, value) VALUES('testProperty2', 1);\
                          INSERT INTO Properties(id, value) VALUES('testProperty3', 1.2);\
                          INSERT INTO Properties(id, value) VALUES('testProperty4', NULL);\
                          \
                          INSERT INTO Calendar(id, nameId, shortNameId, days) VALUES(1, 7, 10, 127);\
                          INSERT INTO Calendar(id, nameId, shortNameId, days) VALUES(2, 8, 11, 127);\
                          INSERT INTO Calendar(id, nameId, shortNameId, days) VALUES(3, 9, 12, 127);\
                          \
                          INSERT INTO Trip(id, calendarId, routeId) VALUES(1, 1, 1);\
                          \
                          INSERT INTO RoutePattern(id, routeId, stopPlaceId, direction, position) VALUES(1, 1, 1, 1, 0);\
                          INSERT INTO RoutePattern(id, routeId, stopPlaceId, direction, position) VALUES(2, 1, 2, 1, 1);\
                          INSERT INTO RoutePattern(id, routeId, stopPlaceId, direction, position) VALUES(3, 1, 4, 1, 3);\
                          INSERT INTO RoutePattern(id, routeId, stopPlaceId, direction, position) VALUES(4, 1, 3, 1, 2);\
                          \
                          INSERT INTO RoutePattern(id, routeId, stopPlaceId, direction, position) VALUES(5, 1, 4, 2, 0);\
                          INSERT INTO RoutePattern(id, routeId, stopPlaceId, direction, position) VALUES(6, 1, 3, 2, 1);\
                          INSERT INTO RoutePattern(id, routeId, stopPlaceId, direction, position) VALUES(7, 1, 1, 2, 3);\
                          INSERT INTO RoutePattern(id, routeId, stopPlaceId, direction, position) VALUES(8, 1, 2, 2, 2);\
                          ", nullptr, nullptr, nullptr);
    
    XCTAssertTrue(status == SQLITE_OK, "Unable to insert test columns, %s", sqlite3_errmsg(self.sqliteDB));
    
    // SELECT id, calendarId, routeId FROM Trip
    
    self.database = [[TKDatabase alloc] initWithPath:self.dbPath];
    NSError *error = nil;
    XCTAssertTrue([self.database openDatabase:&error], "Unable to open the database %@", error);
    XCTAssertTrue([self.database isValid], "The database is marked as non valid");
}

- (void)tearDown {
    [super tearDown];
    
    NSError *error = nil;
    XCTAssertTrue([self.database closeDatabase:&error], "Unable to close the database %@", error);
}

- (void)testFetchStopPlaceByID {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSArray<TKStopPlace *> *stopPlaces = nil;
    __block NSError *fetchError = nil;
    
    TKQuery *query = [[TKQuery alloc] init];
    query.itemID = 1;
    
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 1, @"The number of stop places should be 1, current: %lu", (unsigned long)stopPlaces.count);
    XCTAssertTrue(fetchError == nil, @"Fetching stop places did fail %@", fetchError);
    
    XCTAssertTrue(stopPlaces.firstObject.identifier == 1, @"The stop place identifier is incorrect. It should be 1, current: %lli", stopPlaces.firstObject.identifier);
    XCTAssertTrue([stopPlaces.firstObject.name isEqualToString:@"testPlace1"], @"The stop place name is incorrect. It should be 'testPlace1', current: %@", stopPlaces.firstObject.name);
    
    XCTAssertTrue(stopPlaces.firstObject.location.coordinate.latitude == 0 && stopPlaces.firstObject.location.coordinate.longitude == 0, @"The StopPlace location is incorrect. It should be {0, 0}");
    
    semaphore = dispatch_semaphore_create(0);
    
    query = [[TKQuery alloc] init];
    query.itemID = 000000;
    // Check fetching a non-existing stop place
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 0, @"The number of stop places should be 0, current: %li", stopPlaces.count);
    XCTAssertTrue(fetchError == nil, @"Fetching stop places did fail %@", fetchError);
}

- (void)testFetchStopPlacesByName {
    __block NSArray<TKStopPlace *> *stopPlaces = nil;
    __block NSError *fetchError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    TKQuery *query = [[TKQuery alloc] init];
    query.name = @"testPlace2";
    
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    // Check the nulber of fetched stop places
    XCTAssertTrue(stopPlaces.count == 1, @"The number of stop places should be 1");
    XCTAssertTrue(fetchError == nil, @"Fetching StopPlaces did fail %@", fetchError);
    
    // Check the stop place properties
    XCTAssertTrue(stopPlaces.firstObject.identifier == 2, @"The stop place identifier is incorrect. It should be 1");
    XCTAssertTrue([stopPlaces.firstObject.name isEqualToString:@"testPlace2"], @"The StopPlace name is incorrect. It should be 'testPlace1'");
    
    // Check the stop place location
    XCTAssertTrue(stopPlaces.firstObject.location.coordinate.latitude == 1 && stopPlaces.firstObject.location.coordinate.longitude == 0, @"The StopPlace location is incorrect. It should be {1, 0}");
    
    
    semaphore = dispatch_semaphore_create(0);
    
    query = [[TKQuery alloc] init];
    query.name = @"testPlaceA";
    
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 3, @"The number of StopPlaces should be 3");
    XCTAssertTrue(fetchError == nil, @"Fetching StopPlaces did fail %@", fetchError);
    
    // Check fetching with a limit
    semaphore = dispatch_semaphore_create(0);
    
    query = [[TKQuery alloc] init];
    query.name = @"testPlace";
    query.limit = 2;
    
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 2, @"The number of StopPlaces should be 2");
    XCTAssertTrue(fetchError == nil, @"Fetching StopPlaces did fail %@", fetchError);
}

- (void)testFetchStopPlacesByLocation {
    __block NSArray<TKStopPlace *> *stopPlaces = nil;
    __block NSError *fetchError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    TKQuery *query = [[TKQuery alloc] init];
    query.location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 5, @"The number of stop places should be 5");
    
    // Check the order of the stop places
    XCTAssertTrue(stopPlaces[0].identifier == 1, @"The id of stop place at index 0 should have be 1");
    XCTAssertTrue(stopPlaces[1].identifier == 2, @"The id of stop place at index 1 should have be 2");
    XCTAssertTrue(stopPlaces[2].identifier == 3, @"The id of stop place at index 2 should have be 3");
    XCTAssertTrue(stopPlaces[3].identifier == 4, @"The id of stop place at index 3 should have be 4");
    XCTAssertTrue(stopPlaces[4].identifier == 5, @"The id of stop place at index 4 should have be 5");
    
    // Check fetching with a limit
    semaphore = dispatch_semaphore_create(0);
    
    query = [[TKQuery alloc] init];
    query.location = [[CLLocation alloc] initWithLatitude:0 longitude:0];;
    query.limit = 2;
    
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 2, @"The number of stop places should be 2");
}

- (void)testFetchCalendarByID {
    __block NSArray<TKCalendar *> *calendars = nil;
    __block NSError *fetchError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    TKQuery *query = [[TKQuery alloc] init];
    query.itemID = 1;
    
    [[self.database fetchCalendarWithQuery:query] fetchAllWithCompletion:^(NSArray<TKCalendar *> *result, NSError *error) {
        calendars = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(calendars.count == 1, @"The number of calendars should be 1, current: %lu", (unsigned long)calendars.count);
    XCTAssertTrue(fetchError == nil, @"Fetching calendars did fail %@", fetchError);
    
    XCTAssertTrue(calendars.firstObject.identifier == 1, @"The calendar identifier is incorrect. It should be 1, current: %lli", calendars.firstObject.identifier);
    XCTAssertTrue([calendars.firstObject.name isEqualToString:@"testCalendar1"], @"The calendar name is incorrect. It should be 'testCalendar1', current: %@", calendars.firstObject.name);
    XCTAssertTrue([calendars.firstObject.shortName isEqualToString:@"testCalendar1 ShortName"], @"The calendar short name is incorrect. It should be 'testCalendar1', current: %@", calendars.firstObject.name);
    XCTAssertTrue(calendars.firstObject.days == 127, @"The calendar days is incorrect. It should be '127', current: %i", calendars.firstObject.days);
    
    semaphore = dispatch_semaphore_create(0);
    
    // Check fetching a non-existing calendar
    query = [[TKQuery alloc] init];
    query.itemID = 9999999;
    
    [[self.database fetchCalendarWithQuery:query] fetchAllWithCompletion:^(NSArray<TKCalendar *> *result, NSError *error) {
        calendars = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(calendars.count == 0, @"The number of calendars should be 0");
    XCTAssertTrue(fetchError == nil, @"Fetching calendars did fail %@", fetchError);
}

- (void)testFetchCalendarsByName {
    __block NSArray<TKCalendar *> *calendars = nil;
    __block NSError *fetchError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    TKQuery *query = [[TKQuery alloc] init];
    query.name = @"testCalendar2";
    
    [[self.database fetchCalendarWithQuery:query] fetchAllWithCompletion:^(NSArray<TKCalendar *> *result, NSError *error) {
        calendars = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    // Check the nulber of fetched stop places
    XCTAssertTrue(calendars.count == 1, @"The number of calendars should be 1");
    XCTAssertTrue(fetchError == nil, @"Fetching calendars did fail %@", fetchError);
    
    // Check the calendar properties
    XCTAssertTrue(calendars.firstObject.identifier == 2, @"The calendar identifier is incorrect. It should be 2");
    XCTAssertTrue([calendars.firstObject.name isEqualToString:@"testCalendar2"], @"The calendar name is incorrect. It should be 'testPlace1'");
    XCTAssertTrue([calendars.firstObject.shortName isEqualToString:@"testCalendar2 ShortName"], @"The calendar name is incorrect. It should be 'testPlace1'");
    XCTAssertTrue(calendars.firstObject.days == 127, @"The calendar days property is incorrect. It should be '127', current: %i", calendars.firstObject.days);
    
    semaphore = dispatch_semaphore_create(0);
    
    query = [[TKQuery alloc] init];
    query.name = @"testCalend";
    
    [[self.database fetchCalendarWithQuery:query] fetchAllWithCompletion:^(NSArray<TKCalendar *> *result, NSError *error) {
        calendars = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(calendars.count == 3, @"The number of calendars should be 3");
    XCTAssertTrue(fetchError == nil, @"Fetching calendars did fail %@", fetchError);
    
    // Check fetching with a limit
    semaphore = dispatch_semaphore_create(0);
    
    query = [[TKQuery alloc] init];
    query.name = @"testCalendar";
    query.limit = 2;
    
    [[self.database fetchCalendarWithQuery:query] fetchAllWithCompletion:^(NSArray<TKCalendar *> *result, NSError *error) {
        calendars = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(calendars.count == 2, @"The number of calendars should be , current: %lu", (unsigned long)calendars.count);
    XCTAssertTrue(fetchError == nil, @"Fetching calendars did fail %@", fetchError);
}

- (void)testRoutePatternByRouteId {
    __block NSArray<TKRoutePattern *> *routePatterns = nil;
    __block NSError *fetchError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    TKQuery *query = [[TKQuery alloc] init];
    query.routeID = 1;
    
    [[self.database fetchRoutePatternWithQuery:query] fetchAllWithCompletion:^(NSArray<TKRoutePattern *> *result, NSError *error) {
        routePatterns = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(routePatterns.count == 1, @"The number of route lines should be 1, current: %lu", (unsigned long)routePatterns.count);
    XCTAssertTrue(routePatterns.firstObject.route.identifier == 1, @"The route id of route lines should be 1, current: %lu", (unsigned long)routePatterns.firstObject.route.identifier);
    XCTAssertTrue(routePatterns.firstObject.outboundStopPlaces.count == 4, @"The number of route line outbound stop places should be outbound 4, current: %lu", (unsigned long)routePatterns.firstObject.outboundStopPlaces.count);
    
    XCTAssertTrue(routePatterns.firstObject.outboundStopPlaces[0].identifier == 1
                  && routePatterns.firstObject.outboundStopPlaces[1].identifier == 2
                  && routePatterns.firstObject.outboundStopPlaces[2].identifier == 3
                  && routePatterns.firstObject.outboundStopPlaces[3].identifier == 4, @"The order of route line outbound stop places is incorrect");
    
    XCTAssertTrue(routePatterns.firstObject.inboundStopPlaces.count == 4, @"The number of route line stop places should be outbound 4, current: %lu", (unsigned long)routePatterns.firstObject.inboundStopPlaces.count);
    
    XCTAssertTrue(routePatterns.firstObject.inboundStopPlaces[0].identifier == 4
                  && routePatterns.firstObject.inboundStopPlaces[1].identifier == 3
                  && routePatterns.firstObject.inboundStopPlaces[2].identifier == 2
                  && routePatterns.firstObject.inboundStopPlaces[3].identifier == 1, @"The order of route line inbound stop places is incorrect");
    
    // Fetch non existing route line
    semaphore = dispatch_semaphore_create(0);
    
    query = [[TKQuery alloc] init];
    query.routeID = 999999;
    
    [[self.database fetchRoutePatternWithQuery:query] fetchAllWithCompletion:^(NSArray<TKRoutePattern *> *result, NSError *error) {
        routePatterns = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(routePatterns.count == 0, @"The number of route lines should be 0, current: %lu", (unsigned long)routePatterns.count);
}

- (void)testProperties {
    // Check properties types
    XCTAssertTrue([self.database.properties[@"testProperty1"] isKindOfClass:[NSString class]], @"The 'testProperty1' is not an NSString");
    XCTAssertTrue([self.database.properties[@"testProperty2"] isKindOfClass:[NSNumber class]], @"The 'testProperty1' is not an NSString");
    XCTAssertTrue([self.database.properties[@"testProperty3"] isKindOfClass:[NSNumber class]], @"The 'testProperty1' is not an NSString");
    XCTAssertTrue([self.database.properties[@"testProperty4"] isKindOfClass:[NSNull class]], @"The 'testProperty1' is not an NSString");
    
    // Check properties values
    XCTAssertTrue([self.database.properties[@"testProperty1"] isEqualToString:@"testProperty"], @"The 'testProperty1' property value should be 'testProperty'");
    XCTAssertTrue([self.database.properties[@"testProperty2"] isEqual:@(1)], @"The 'testProperty1' property value should be 'testProperty'");
    XCTAssertTrue([self.database.properties[@"testProperty3"] isEqual:@(1.2)], @"The 'testProperty1' property value should be 'testProperty'");
    XCTAssertTrue([self.database.properties[@"testProperty4"] isEqual:[NSNull null]], @"The 'testProperty1' property value should be 'testProperty'");
}
    
- (void)testLanguages {
    self.database.selectedLanguage = @"ar";
    
    // Fetch StopPlace by id
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSArray<TKStopPlace *> *stopPlaces = nil;
    __block NSError *fetchError = nil;
    
    TKQuery *query = [[TKQuery alloc] init];
    query.itemID = 1;
    
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 1, @"The number of stop places should be 1");
    XCTAssertTrue(fetchError == nil, @"Fetching stop places did fail %@", fetchError);
    
    XCTAssertTrue(stopPlaces.firstObject.identifier == 1, @"The stop place identifier is incorrect. It should be 1");
    XCTAssertTrue([stopPlaces.firstObject.name isEqualToString:@"testPlace1-ar"], @"The stop place name is incorrect. It should be 'testPlace1-de'");
    
    // Fetch StopPlace by name
    semaphore = dispatch_semaphore_create(0);
    
    stopPlaces = nil;
    fetchError = nil;
    
    query = [[TKQuery alloc] init];
    query.itemID = 1;
    
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 1, @"The number of stop places should be 1");
    XCTAssertTrue(fetchError == nil, @"Fetching stop places did fail %@", fetchError);
    
    XCTAssertTrue(stopPlaces.firstObject.identifier == 1, @"The stop place identifier is incorrect. It should be 1");
    XCTAssertTrue([stopPlaces.firstObject.name isEqualToString:@"testPlace1-ar"], @"The stop place name is incorrect. It should be 'testPlace1-de'");
    
    // Fetch StopPlace by location
    semaphore = dispatch_semaphore_create(0);
    
    stopPlaces = nil;
    fetchError = nil;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    
    query = [[TKQuery alloc] init];
    query.location = location;
    query.limit = 1;
    
    [[self.database fetchStopPlaceWithQuery:query] fetchAllWithCompletion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 1, @"The number of stop places should be 1");
    XCTAssertTrue(fetchError == nil, @"Fetching stop places did fail %@", fetchError);
    
    XCTAssertTrue(stopPlaces.firstObject.identifier == 1, @"The stop place identifier is incorrect. It should be 1");
    XCTAssertTrue([stopPlaces.firstObject.name isEqualToString:@"testPlace1-ar"], @"The stop place name is incorrect. It should be 'testPlace1-de'");
    
}

@end
