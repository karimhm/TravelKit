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
                              color INT\
                          );\
                          CREATE TABLE IF NOT EXISTS Calendar (\
                              id INTEGER PRIMARY KEY NOT NULL,\
                              nameId INTEGER REFERENCES Localization(id),\
                              days INT CHECK (days <= 127) NOT NULL\
                          );\
                          CREATE TABLE IF NOT EXISTS Trip (\
                              id INTEGER PRIMARY KEY NOT NULL,\
                              calendarId INTEGER REFERENCES Calendar(id) NOT NULL,\
                              routeId INTEGER REFERENCES Route(id) NOT NULL\
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
                          INSERT INTO Localization(id, language, text) VALUES(7, 'en', 'testCalendar1');\
                          INSERT INTO Localization(id, language, text) VALUES(8, 'en', 'testCalendar2');\
                          INSERT INTO Localization(id, language, text) VALUES(9, 'en', 'testCalendar3');\
                          \
                          INSERT INTO Localization(id, language, text) VALUES(1, 'ar', 'testPlace1-ar');\
                          \
                          INSERT INTO Route(id, nameId, color) VALUES(1, 6, 16777215);\
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
                          INSERT INTO Calendar(id, nameId, days) VALUES(1, 7, 127);\
                          INSERT INTO Calendar(id, nameId, days) VALUES(2, 8, 127);\
                          INSERT INTO Calendar(id, nameId, days) VALUES(3, 9, 127);\
                          \
                          INSERT INTO Trip(id, calendarId, routeId) VALUES(1, 1, 1);\
                          ", nullptr, nullptr, nullptr);
    
    XCTAssertTrue(status == SQLITE_OK, "Unable to insert test columns");
    
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
    
    [self.database fetchStopPlaceWithID:1 completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 1, @"The number of stop places should be 1");
    XCTAssertTrue(fetchError == nil, @"Fetching stop places did fail %@", fetchError);
    
    XCTAssertTrue(stopPlaces.firstObject.identifier == 1, @"The stop place identifier is incorrect. It should be 1");
    XCTAssertTrue([stopPlaces.firstObject.name isEqualToString:@"testPlace1"], @"The stop place name is incorrect. It should be 'testPlace1'");
    
    XCTAssertTrue(stopPlaces.firstObject.location.coordinate.latitude == 0 && stopPlaces.firstObject.location.coordinate.longitude == 0, @"The StopPlace location is incorrect. It should be {0, 0}");
    
    semaphore = dispatch_semaphore_create(0);
    
    // Check fetching a non-existing stop place
    [self.database fetchStopPlaceWithID:9999999 completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 0, @"The number of stop places should be 0");
    XCTAssertTrue(fetchError == nil, @"Fetching stop places did fail %@", fetchError);
}

- (void)testFetchStopPlacesByName {
    __block NSArray<TKStopPlace *> *stopPlaces = nil;
    __block NSError *fetchError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.database fetchStopPlacesWithName:@"testPlace2" completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
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
    [self.database fetchStopPlacesWithName:@"testPlaceA" completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 3, @"The number of StopPlaces should be 3");
    XCTAssertTrue(fetchError == nil, @"Fetching StopPlaces did fail %@", fetchError);
    
    // Check fetching with a limit
    semaphore = dispatch_semaphore_create(0);
    [self.database fetchStopPlacesWithName:@"testPlace" completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    } limit:2];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 2, @"The number of StopPlaces should be 2");
    XCTAssertTrue(fetchError == nil, @"Fetching StopPlaces did fail %@", fetchError);
}

- (void)testFetchStopPlacesByLocation {
    __block NSArray<TKStopPlace *> *stopPlaces = nil;
    __block NSError *fetchError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    [self.database fetchStopPlacesWithLocation:location completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
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
    [self.database fetchStopPlacesWithLocation:location completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    } limit:2];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 2, @"The number of stop places should be 2");
    NSLog(@"%@", stopPlaces);
}

- (void)testFetchCalendarByID {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSArray<TKCalendar *> *calendars = nil;
    __block NSError *fetchError = nil;
    
    
    [self.database fetchCalendarWithID:1 completion:^(NSArray<TKCalendar *> *result, NSError *error) {
        calendars = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(calendars.count == 1, @"The number of calendars should be 1");
    XCTAssertTrue(fetchError == nil, @"Fetching calendars did fail %@", fetchError);
    
    XCTAssertTrue(calendars.firstObject.identifier == 1, @"The calendar identifier is incorrect. It should be 1");
    XCTAssertTrue([calendars.firstObject.name isEqualToString:@"testCalendar1"], @"The calendar name is incorrect. It should be 'testCalendar1'");
    XCTAssertTrue(calendars.firstObject.days == 127, @"The calendar days is incorrect. It should be '127', current: %i", calendars.firstObject.days);
    
    semaphore = dispatch_semaphore_create(0);
    
    // Check fetching a non-existing calendar
    [self.database fetchCalendarWithID:9999999 completion:^(NSArray<TKCalendar *> *result, NSError *error) {
        calendars = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(calendars.count == 0, @"The number of calendars should be 0");
    XCTAssertTrue(fetchError == nil, @"Fetching calendars did fail %@", fetchError);
}

- (void)testFetchCalendarsByName {
    __block NSArray<TKCalendar *> *calendars = nil;
    __block NSError *fetchError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.database fetchCalendarsWithName:@"testCalendar2" completion:^(NSArray<TKCalendar *> *result, NSError *error) {
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
    XCTAssertTrue(calendars.firstObject.days == 127, @"The calendar days property is incorrect. It should be '127', current: %i", calendars.firstObject.days);
    
    semaphore = dispatch_semaphore_create(0);
    [self.database fetchCalendarsWithName:@"testCalend" completion:^(NSArray<TKCalendar *> *result, NSError *error) {
        calendars = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(calendars.count == 3, @"The number of calendars should be 3");
    XCTAssertTrue(fetchError == nil, @"Fetching calendars did fail %@", fetchError);
    
    // Check fetching with a limit
    semaphore = dispatch_semaphore_create(0);
    [self.database fetchCalendarsWithName:@"testCalendar" completion:^(NSArray<TKCalendar *> *result, NSError *error) {
        calendars = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    } limit:2];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(calendars.count == 2, @"The number of calendars should be , current: %lu", (unsigned long)calendars.count);
    XCTAssertTrue(fetchError == nil, @"Fetching calendars did fail %@", fetchError);
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
    
    [self.database fetchStopPlaceWithID:1 completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
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
    
    [self.database fetchStopPlacesWithName:@"testPlace1" completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
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
    [self.database fetchStopPlacesWithLocation:location completion:^(NSArray<TKStopPlace *> *result, NSError *error) {
        stopPlaces = result;
        fetchError = error;
        dispatch_semaphore_signal(semaphore);
    } limit:1];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(stopPlaces.count == 1, @"The number of stop places should be 1");
    XCTAssertTrue(fetchError == nil, @"Fetching stop places did fail %@", fetchError);
    
    XCTAssertTrue(stopPlaces.firstObject.identifier == 1, @"The stop place identifier is incorrect. It should be 1");
    XCTAssertTrue([stopPlaces.firstObject.name isEqualToString:@"testPlace1-ar"], @"The stop place name is incorrect. It should be 'testPlace1-de'");
    
}

@end
