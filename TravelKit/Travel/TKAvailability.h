/*
 *  TKAvailability.h
 *  Created on 19/May/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <Foundation/Foundation.h>

@interface TKAvailability : TKItem

@property (strong, nonatomic, readonly) NSString *name;

- (BOOL)availableAtDate:(NSDate *)date;

@end
