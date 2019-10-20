/*
 *  TKStopTime.h
 *  Created on 5/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKStopPlace.h>
#import <TravelKit/TKCalendar.h>
#import <TravelKit/TKTime.h>

NS_ASSUME_NONNULL_BEGIN

@class TKTrip;

NS_SWIFT_NAME(StopTime)
@interface TKStopTime : TKItem

@property (strong, nonatomic, readonly) TKStopPlace *stopPlace;
@property (strong, nonatomic, readonly) TKTrip *trip;
@property (strong, nonatomic, readonly, nullable) TKCalendar *calendar;
@property (strong, nonatomic, readonly) TKTime *arrival;

@end

NS_ASSUME_NONNULL_END
