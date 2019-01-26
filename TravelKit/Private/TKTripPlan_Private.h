/*
 *  TKTripPlan_Private.h
 *  Created on 26/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKTripPlan.h"

@interface TKTripPlan ()

- (instancetype)initWithSource:(TKStopPlace *)source destination:(TKStopPlace *)destination date:(NSDate *)date itineraries:(NSArray<TKItinerary *> *)itineraries;

@end
