/*
 *  TKItinerary.m
 *  Created on 18/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKItinerary.h"

@implementation TKItinerary

- (instancetype)initWithRides:(NSArray<TKRide *> *)rides {
    return [self initWithRides:rides
                 departureDate:rides.firstObject.stops.firstObject.date
                   arrivalDate:rides.lastObject.stops.lastObject.date
                        source:rides.firstObject.stops.firstObject.stopPlace
                   destination:rides.lastObject.stops.lastObject.stopPlace];
}

- (instancetype)initWithRides:(NSArray<TKRide *> *)rides departureDate:(NSDate *)departureDate arrivalDate:(NSDate *)arrivalDate source:(TKStopPlace *)source destination:(TKStopPlace *)destination {
    if (self = [super init]) {
        _rides = rides;
        _departureDate = departureDate;
        _arrivalDate = arrivalDate;
        _source = source;
        _destination = destination;
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    TKItinerary *itinerary = [[[self class] allocWithZone:zone] init];
    itinerary->_rides = self.rides;
    itinerary->_departureDate = self.departureDate;
    itinerary->_arrivalDate = self.arrivalDate;
    itinerary->_source = self.source;
    itinerary->_destination = self.destination;
    
    return itinerary;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    TK_ENCODE_OBJ(aCoder, rides);
    TK_ENCODE_OBJ(aCoder, departureDate);
    TK_ENCODE_OBJ(aCoder, arrivalDate);
    TK_ENCODE_OBJ(aCoder, source);
    TK_ENCODE_OBJ(aCoder, destination);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        TK_DECODE_OBJ_ARRAY(aDecoder, rides, NSArray<TKRide *>);
        TK_DECODE_OBJ_CLASS(aDecoder, departureDate, NSDate);
        TK_DECODE_OBJ_CLASS(aDecoder, arrivalDate, NSDate);
        TK_DECODE_OBJ_CLASS(aDecoder, source, TKStopPlace);
        TK_DECODE_OBJ_CLASS(aDecoder, destination, TKStopPlace);
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return true;
}

- (void)dealloc {
    _rides = nil;
    _departureDate = nil;
    _arrivalDate = nil;
    _source = nil;
    _destination = nil;
}

@end
