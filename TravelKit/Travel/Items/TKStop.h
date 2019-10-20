/*
 *  TKStop.h
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKStopPlace.h>
#import <Foundation/Foundation.h>

NS_SWIFT_NAME(Stop)
@interface TKStop : NSObject <NSCopying, NSCoding, NSSecureCoding>

@property (strong, nonatomic, readonly) TKStopPlace *stopPlace;
@property (strong, nonatomic, readonly) NSDate *date;

@end
