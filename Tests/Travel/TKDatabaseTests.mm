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
                              name TEXT NOT NULL,\
                              latitude DOUBLE NOT NULL,\
                              longitude DOUBLE NOT NULL\
                          );\
                          CREATE TABLE Properties (\
                              id TEXT,\
                              value BLOB\
                          );\
                          ", nullptr, nullptr, nullptr);
    
    XCTAssertTrue(status == SQLITE_OK, "Unable to create stop places table");
    
    status = sqlite3_exec(self.sqliteDB, "\
                          INSERT INTO StopPlace(id, name, latitude, longitude) VALUES(1, 'testPlace1', 0, 0);\
                          INSERT INTO StopPlace(id, name, latitude, longitude) VALUES(2, 'testPlace2', 1, 0);\
                          INSERT INTO StopPlace(id, name, latitude, longitude) VALUES(3, 'testPlaceA1', 2, 0);\
                          INSERT INTO StopPlace(id, name, latitude, longitude) VALUES(4, 'testPlaceA2', 3, 0);\
                          INSERT INTO StopPlace(id, name, latitude, longitude) VALUES(5, 'testPlaceA3', 4, 0);\
                          INSERT INTO Properties(id, value) VALUES('testProperty1', 'testProperty');\
                          INSERT INTO Properties(id, value) VALUES('testProperty2', 1);\
                          INSERT INTO Properties(id, value) VALUES('testProperty3', 1.2);\
                          INSERT INTO Properties(id, value) VALUES('testProperty4', NULL);\
                          ", nullptr, nullptr, nullptr);
    
    XCTAssertTrue(status == SQLITE_OK, "Unable to insert a test columns");
    
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

@end
