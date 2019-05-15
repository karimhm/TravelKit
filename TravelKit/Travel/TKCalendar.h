/*
 *  TKCalendar.h
 *  Created on 15/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKCalendar : TKItem

@property (strong, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) uint8_t days;

@end

NS_ASSUME_NONNULL_END
