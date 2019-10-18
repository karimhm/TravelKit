/*
*  TKTrip.mm
*  Created on 18/Oct/19.
*
*  Copyright (C) 2019 Karim. All rights reserved.
*/

#import "TKTrip.h"
#import "TKDefines_Private.h"

@implementation TKTrip

- (void)setRoute:(TKRoute *)route {
    _route = route;
}

- (void)setStopTimes:(NSArray<TKStopTime *> *)stopTimes {
    _stopTimes = stopTimes;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    TKTrip *trip = [[[self class] allocWithZone:zone] init];
    trip->_route = self.route;
    trip->_stopTimes = self.stopTimes;
    
    return trip;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    TK_ENCODE_OBJ(aCoder, route);
    TK_ENCODE_OBJ(aCoder, stopTimes);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        TK_DECODE_OBJ_CLASS(aDecoder, route, TKRoute);
        TK_DECODE_OBJ_ARRAY(aDecoder, stopTimes, TKStopTime);
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return true;
}

#pragma mark -

- (void)dealloc {
    _route = nil;
    _stopTimes = nil;
}


@end
