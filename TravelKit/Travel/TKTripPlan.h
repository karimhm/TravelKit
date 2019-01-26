/*
 *  TKTripPlan.h
 *  Created on 26/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKStopPlace.h>
#import <TravelKit/TKItinerary.h>

@interface TKTripPlan : NSObject

@property (readonly, nonatomic) TKStopPlace *source;
@property (readonly, nonatomic) TKStopPlace *destination;

@property (readonly, nonatomic) NSDate *date;

@property (readonly, nonatomic) NSArray<TKItinerary *> *itineraries;

@end
