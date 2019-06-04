/*
 *  TKStopTime.h
 *  Created on 5/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKStopPlace.h>
#import <TravelKit/TKCalendar.h>

@interface TKTime : NSObject <NSCopying, NSCoding, NSSecureCoding>

@property (nonatomic, readonly) NSInteger second;
@property (nonatomic, readonly) NSInteger hour;
@property (nonatomic, readonly) NSInteger minute;
@property (nonatomic, readonly) NSInteger day;

@end

@interface TKStopTime : TKItem

@property (strong, nonatomic, readonly) TKStopPlace *stopPlace;
@property (strong, nonatomic, readonly) TKCalendar *calendar;
@property (strong, nonatomic, readonly) TKTime *arrival;

@end
