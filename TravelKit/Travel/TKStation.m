/*
 *  TKStation.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStation.h"
#import "TKItem_Private.h"

@implementation TKStation

- (instancetype)initWithRow:(id <TKDBRow>)row {
    if (self = [super initWithRow:row]) {
        _name = [row stringForColumn:kTKColumnName];
        _location = [[CLLocation alloc] initWithLatitude:[row doubleForColumn:kTKColumnLatitude]
                                               longitude:[row doubleForColumn:kTKColumnLongitude]];
    }
    return self;
}

#pragma mark - TKDBVerify

+ (NSString *)databaseTableName {
    return kTKTableStation;
}

+ (NSArray <NSString *> *)tableRequiredColumns {
    return @[kTKColumnName,
             kTKColumnLatitude,
             kTKColumnLongitude];
}

#pragma mark -

- (void)dealloc {
    _name = nil;
    _location = nil;
}

@end
