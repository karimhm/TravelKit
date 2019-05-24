/*
 *  TKRouteLine.h
 *  Created on 20/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <TravelKit/TKRoute.h>
#import <TravelKit/TKStopPlace.h>

@interface TKRouteLine : TKItem

@property (nonatomic, readonly) TKRoute *route;
@property (nonatomic, readonly) NSArray<TKStopPlace *> *outboundStopPlaces;
@property (nonatomic, readonly) NSArray<TKStopPlace *> *inboundStopPlaces;

@end
