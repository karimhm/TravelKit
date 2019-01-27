/*
 *  TKItinerary_Private.h
 *  Created on 21/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKItinerary.h"

@interface TKItinerary ()

- (instancetype)initWithRides:(NSArray<TKRide *> *)rides;
- (instancetype)initWithRides:(NSArray<TKRide *> *)rides departureDate:(NSDate *)departureDate arrivalDate:(NSDate *)arrivalDate;

@end
