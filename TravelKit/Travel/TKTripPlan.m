/*
 *  TKTripPlan.m
 *  Created on 26/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKTripPlan.h"

@implementation TKTripPlan

- (instancetype)initWithSource:(TKStopPlace *)source destination:(TKStopPlace *)destination date:(NSDate *)date itineraries:(NSArray<TKItinerary *> *)itineraries {
    if (self = [super init]) {
        _source = source;
        _destination = destination;
        _date = date;
        _itineraries = itineraries;
    }
    return self;
}

- (void)dealloc {
    _source = nil;
    _destination = nil;
    _date = nil;
    _itineraries = nil;
}

@end
