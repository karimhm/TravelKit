/*
 *  TKTimeFormatter.h
 *  Created on 5/Jun/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKTime.h>
#import <Foundation/Foundation.h>

@interface TKTimeFormatter : NSFormatter

- (nullable NSString *)stringFromTime:(TKTime *)time;

+ (NSString *)localizedStringFromTime:(TKTime *)time;

@end
