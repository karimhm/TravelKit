/*
 *  TKItinerary.m
 *  Created on 18/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKItinerary.h"

@implementation TKItinerary

- (instancetype)initWithRides:(NSArray<TKRide *> *)rides {
    if (self = [super init]) {
        _rides = rides;
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    TKItinerary *itinerary = [[[self class] allocWithZone:zone] init];
    itinerary->_rides = self.rides;
    
    return itinerary;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    TK_ENCODE_OBJ(aCoder, rides);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        TK_DECODE_OBJ_ARRAY(aDecoder, rides, NSArray<TKRide *>);
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return true;
}

- (void)dealloc {
    _rides = nil;
}

@end
