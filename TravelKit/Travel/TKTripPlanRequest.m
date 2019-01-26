/*
 *  TKTripPlanRequest.m
 *  Created on 18/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKTripPlanRequest.h"

@implementation TKTripPlanRequest

- (instancetype)initWithSource:(TKStopPlace *)source destination:(TKStopPlace *)destination {
    if (self = [super init]) {
        _source = source;
        _destination = destination;
    }
    return self;
}

- (void)dealloc {
    _source = nil;
    _destination = nil;
}

@end
