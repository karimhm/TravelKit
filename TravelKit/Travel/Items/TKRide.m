/*
 *  TKRide.m
 *  Created on 26/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKRide.h"
#import "TKRide_Private.h"
#import "TKDefines_Private.h"

@implementation TKRide

- (instancetype)initWithStops:(NSArray<TKStop *> *)stops route:(TKRoute *)route {
    if (self = [super init]) {
        _stops = stops;
        _route = route;
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    TKRide *ride = [[[self class] allocWithZone:zone] init];
    ride->_stops = self.stops;
    ride->_route = self.route;
    
    return ride;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    TK_ENCODE_OBJ(aCoder, stops);
    TK_ENCODE_OBJ(aCoder, route);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        TK_DECODE_OBJ_ARRAY(aDecoder, stops, TKStop);
        TK_DECODE_OBJ_CLASS(aDecoder, route, TKRoute);
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return true;
}

#pragma mark -

- (void)dealloc {
    _stops = nil;
    _route = nil;
}

@end
