/*
 *  NSDateComponents+TravelKit.m
 *  Created on 6/Jul/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "NSDateComponents+TravelKit.h"
#import "TKUtilities.h"

@implementation NSDateComponents (TravelKit)

+ (instancetype)tk_dateComponentsWithTime:(int32_t)time {
    int32_t hour = time / 3600;
    int32_t minute = (time = time % 3600) / 60;
    int32_t second = (time = time % 60);
    
    NSDateComponents *dateComponents = [self.class new];
    dateComponents.hour = hour;
    dateComponents.minute = minute;
    dateComponents.second = second;
    
    return dateComponents;
}

@end
