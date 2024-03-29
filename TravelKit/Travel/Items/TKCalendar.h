/*
 *  TKCalendar.h
 *  Created on 15/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Calendar)
@interface TKCalendar : TKItem

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *shortName;
@property (nonatomic, readonly) uint8_t days;

@property (strong, nonatomic, readonly, nullable) NSTimeZone *timeZone;

- (BOOL)isAvailableAtDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
