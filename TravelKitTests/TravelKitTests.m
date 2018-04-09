/*
 *  TravelKitTests.m
 *  Created on 22/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "TKDatabase.h"
#import "TKContainer.h"
#import "TKDBFunction.h"
#import "TKStatement.h"

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

typedef struct {
    TKDBValueType *types;
    int count;
} TFExpectedValues;

void TKDBTestFuction(TKDBContextRef context, int valuesCount, TKDBValueRef _Nonnull * _Nonnull values) {
    if (valuesCount == 1 && TKDBValueGetType(values[0]) == TKDBValueTypeText) {
        TKDBContextResultInt64(context, 1);
    } else {
        TKDBContextResultNull(context);
    }
}

static TKDBValueType types[] = {TKDBValueTypeNull, TKDBValueTypeInteger, TKDBValueTypeFloat, TKDBValueTypeText, TKDBValueTypeBlob};
static TFExpectedValues values = {types, sizeof(types) / sizeof(TKDBValueType)};

- (void)testCustomFunction {
    NSError *error = nil;
    TKDatabase *db = [[TKDatabase alloc] initWithURL:self.dbURL];
    
    BOOL openStatus = [db open];
    XCTAssertTrue(openStatus, "Unable to open the database");
    
    TKDBFunctionContext testFunction = {NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL};
    testFunction.name = "tkTestFunction";
    testFunction.valuesCount = 1;
    testFunction.deterministic = true;
    testFunction.execute = TKDBTestFuction;
    testFunction.info = &values;
    
    [db addFunction:testFunction error:&error];
    XCTAssertNil(error, "Adding a custom function did fail");
    
    TKStatement *statement = [[TKStatement alloc] initWithDatabase:db format:@"select tkTestFunction('Kar') as testValue"];
    [statement prepareWithError:&error];
    XCTAssertNil(error, "Preparing the statement did fail");
    
    id<TKDBRow> row = [statement next];
    
    TKDBValueType type = [row valueTypeForColumn:@"testValue"];
    XCTAssertTrue(type == TKDBValueTypeInteger, "Expected type is 'Integer'");
    
    int64_t value = [row int64ForColumn:@"testValue"];
    XCTAssertTrue(value == 1, "Expected value is '1' current value is %lli", value);
}

- (void)testFetchingStations {
    NSError *error = nil;
    TKContainer *container = [[TKContainer alloc] initWithURL:self.dbURL error:&error];
    
    XCTAssertNil(error, "Container initialization did fail error: %@", error);
    
    [container fetchStationsMatchingName:@"" limit:-1 completion:^(NSArray<TKStation *> * response, NSError * rerror){
        XCTAssertNil(error, "Fetching did fail with error: %@", rerror);
    }];
}

- (void)testFetchingStationsPerformance {
    NSError *error = nil;
    TKContainer *container = [[TKContainer alloc] initWithURL:self.dbURL error:&error];
    
    [self measureBlock:^{
        [container fetchStationsMatchingName:@"" limit:-1 completion:^(NSArray<TKStation *> * response, NSError * rerror){
        }];
    }];
}

@end
