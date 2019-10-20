/*
*  TKTrip.h
*  Created on 18/Oct/19.
*
*  Copyright (C) 2019 Karim. All rights reserved.
*/

#import <TravelKit/TKItem.h>
#import <TravelKit/TKRoute.h>
#import <TravelKit/TKStopTime.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Trip)
@interface TKTrip : TKItem

@property (nonatomic, readonly) TKRoute *route;
@property (nonatomic, readonly, nullable) NSArray<TKStopTime *> *stopTimes;

@end

NS_ASSUME_NONNULL_END
