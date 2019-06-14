/*
 *  TKStopTime.h
 *  Created on 5/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKStopPlace.h>
#import <TravelKit/TKCalendar.h>
#import <TravelKit/TKTime.h>

@interface TKStopTime : TKItem

@property (strong, nonatomic, readonly) TKStopPlace *stopPlace;
@property (strong, nonatomic, readonly) TKCalendar *calendar;
@property (strong, nonatomic, readonly) TKTime *arrival;

@end
