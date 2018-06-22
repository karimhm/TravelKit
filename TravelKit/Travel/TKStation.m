/*
 *  TKStation.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStation.h"
#import "TKItem_Private.h"

@implementation TKStation

- (instancetype)initWithRow:(id <TKDBRow>)row manager:(id <TKItemManager>)manager {
    if (self = [super initWithRow:row manager:manager]) {
        _name = [row stringForColumn:kTKColumnName];
        _location = [[CLLocation alloc] initWithLatitude:[row doubleForColumn:kTKColumnLatitude]
                                               longitude:[row doubleForColumn:kTKColumnLongitude]];
        
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object != nil && [object class] == [self class]) {
        return [self identifier] == [(TKStation *)object identifier];
    } else {
        return false;
    }
}

- (NSString *)tableName {
    return kTKTableStation;
}

#pragma mark - TKDBVerify

+ (TKDBVerifySet *)requiredTablesAndColumns {
    return @{kTKTableStation:@[kTKColumnName,
                               kTKColumnLatitude,
                               kTKColumnLongitude]
             };
}

#pragma mark -

- (void)dealloc {
    _name = nil;
    _location = nil;
}

@end
