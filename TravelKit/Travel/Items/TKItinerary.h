/*
 *  TKItinerary.h
 *  Created on 18/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKRide.h>
#import <TravelKit/TKStopPlace.h>

NS_SWIFT_NAME(Itinerary)
@interface TKItinerary : NSObject <NSCopying, NSCoding, NSSecureCoding>

@property (readonly, nonatomic) NSArray<TKRide *> *rides;

@property (readonly, nonatomic) TKStopPlace *source;
@property (readonly, nonatomic) TKStopPlace *destination;

@property (readonly, nonatomic) NSDate *departureDate;
@property (readonly, nonatomic) NSDate *arrivalDate;

@end
