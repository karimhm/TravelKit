/*
 *  TKRouteLine.h
 *  Created on 20/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <TravelKit/TKRoute.h>
#import <TravelKit/TKStopPlace.h>

typedef NS_OPTIONS(NSInteger, TKTravelDirection) {
    TKTravelDirectionUnknown         = 0,
    TKTravelDirectionOutbound        = 1,
    TKTravelDirectionInbound         = 2
};

@interface TKRouteLine : TKItem

@property (nonatomic, readonly) TKRoute *route;
@property (nonatomic, readonly) NSArray<TKStopPlace *> *stopPlaces;
@property (nonatomic, readonly) TKTravelDirection direction;

@end
