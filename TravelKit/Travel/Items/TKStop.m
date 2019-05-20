/*
 *  TKStop.m
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStop.h"
#import "TKDefines_Private.h"

@implementation TKStop

- (instancetype)initWithStopPlace:(TKStopPlace *)stopPlace date:(NSDate *)date {
    if (self = [super init]) {
        _stopPlace = stopPlace;
        _date = date;
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    TKStop *stop = [[[self class] allocWithZone:zone] init];
    stop->_stopPlace = self.stopPlace;
    stop->_date = self.date;
    
    return stop;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    TK_ENCODE_OBJ(aCoder, stopPlace);
    TK_ENCODE_OBJ(aCoder, date);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        TK_DECODE_OBJ_CLASS(aDecoder, stopPlace, TKStopPlace);
        TK_DECODE_OBJ_CLASS(aDecoder, date, NSDate);
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return true;
}

- (void)dealloc {
    _stopPlace = nil;
    _date = nil;
}

@end
