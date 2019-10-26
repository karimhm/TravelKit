/*
 *  TKRouterTests.m
 *  Created on 3/Aug/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "TKDatabase.h"

@interface TKRouterTests : XCTestCase

@property (strong, nonatomic) TKDatabase *database;

@end

@implementation TKRouterTests

- (void)setUp {
    [super setUp];
    
    self.database = [[TKDatabase alloc] initWithPath:@"/Users/karim/Desktop/Transportation/sn data/local_data/1445/SNTF.trdb"];
    NSError *error = nil;
    XCTAssertTrue([self.database openDatabase:&error], "Unable to open the database %@", error);
    XCTAssertTrue([self.database isValid], "The database is marked as non valid");
}

- (void)testFetchTripPlan {
    TKQuery *sourceQuery = [[TKQuery alloc] init];
    sourceQuery.name = @"Blida";
    
    TKQuery *destinationQuery = [[TKQuery alloc] init];
    destinationQuery.name = @"Bab Ezzouar";
    
    TKStopPlace *source = [[self.database fetchStopPlaceWithQuery:sourceQuery] fetchOne];
    TKStopPlace *destination = [[self.database fetchStopPlaceWithQuery:destinationQuery] fetchOne];
    
    NSLog(@"From: %@ -> %@", source.name, destination.name);
    
    TKTripPlanRequest *request = [[TKTripPlanRequest alloc] init];
    request.source = source;
    request.destination = destination;
    
    [self.database fetchTripPlanWithRequest:request completion:^(TKTripPlan * _Nullable result, NSError * _Nullable error) {
        NSLog(@"Count: %i", (int)result.itineraries.count);
    }];
}

@end
