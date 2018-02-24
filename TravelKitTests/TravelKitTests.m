/*
 *  TravelKitTests.m
 *  Created on 22/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "TKDatabase.h"
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

- (void)testLoadingDatabase {
    NSError *error = nil;
    TKDatabase *db = [[TKDatabase alloc] initWithURL:self.dbURL];
    
    [db openWithOptions:TKDBOptionsOpenReadOnly error:&error];
    XCTAssertNil(error, "Unable to open test database");
}

- (void)testLoadingContainer {
    NSError *error = nil;
    TKContainer *db = [[TKContainer alloc] initWithURL:self.dbURL error:&error];
    XCTAssertNil(error, "Container allocation did failed");
    XCTAssertTrue(db.valid, "Container is marked as non valid");
}

- (void)testPerformanceLoadingStations {
    NSError *error = nil;
    TKContainer *cont = [[TKContainer alloc] initWithURL:self.dbURL error:&error];
    
    [self measureBlock:^{
        [cont loadStations];
    }];
}

@end
