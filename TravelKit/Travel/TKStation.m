/*
 *  TKStation.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStation.h"
#import "TKItem_Private.h"

@implementation TKStation

- (instancetype)copyWithZone:(NSZone *)zone {
    TKStation *station = [super copyWithZone:zone];
    station->_name = self.name;
    station->_location = self.location;
    
    return station;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    TK_ENCODE_OBJ(aCoder, name);
    TK_ENCODE_OBJ(aCoder, location);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        TK_DECODE_OBJ_CLASS(aDecoder, name, NSString);
        TK_DECODE_OBJ_CLASS(aDecoder, location, CLLocation);
    }
    return self;
}

- (instancetype)initWithRow:(id <TKDBRow>)row manager:(id <TKItemManager>)manager {
    if (self = [super initWithRow:row manager:manager]) {
        _name = [row stringForColumn:kTKColumnName];
        _location = [[CLLocation alloc] initWithLatitude:[row doubleForColumn:kTKColumnLatitude]
                                               longitude:[row doubleForColumn:kTKColumnLongitude]];
        
    }
    return self;
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
