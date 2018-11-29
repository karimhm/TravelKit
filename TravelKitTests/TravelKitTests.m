/*
 *  TravelKitTests.m
 *  Created on 22/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "TKContainer.h"

@interface TravelKitTests : XCTestCase

@property (strong, nonatomic) NSBundle *currentBundle;
@property (strong, nonatomic) NSURL *dbURL;

@end

@implementation TravelKitTests

- (NSBundle *)currentBundle {
    return [NSBundle bundleForClass:[self class]];
}

- (NSURL *)dbURL {
    return [self.currentBundle URLForResource:@"data" withExtension:@"db"];
}

- (void)testLoadingContainer {
    NSError *error = nil;
    TKContainer *db = [[TKContainer alloc] initWithURL:self.dbURL error:&error];
    XCTAssertNil(error, "Container allocation did failed");
    XCTAssertTrue(db.valid, "Container is marked as non valid");
}

- (void)testFetchingStations {
    NSError *error = nil;
    TKContainer *container = [[TKContainer alloc] initWithURL:self.dbURL error:&error];
    NSLog(@"%@", error);
    XCTAssertNil(error, "Container initialization did fail error: %@", error);
    
    [container fetchStationsMatchingName:@"" limit:-1 completion:^(NSArray<TKStation *> * result, NSError * rerror){
        XCTAssertNil(error, "Fetching did fail with error: %@", rerror);
    }];
}

- (void)testFetchingStationsPerformance {
    NSError *error = nil;
    TKContainer *container = [[TKContainer alloc] initWithURL:self.dbURL error:&error];
    
    [self measureBlock:^{
        [container fetchStationsMatchingName:@"" limit:-1 completion:^(NSArray<TKStation *> * result, NSError * rerror){
        }];
    }];
}

- (void)testFetchingStationsByLocationPerformance {
    NSError *error = nil;
    TKContainer *container = [[TKContainer alloc] initWithURL:self.dbURL error:&error];
    
    [self measureBlock:^{
        CLLocation *location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        [container fetchStationsNearLocation:location limit:100 completion:^(NSArray<TKStation *> * result, NSError * rerror){
        }];
    }];
}

@end
