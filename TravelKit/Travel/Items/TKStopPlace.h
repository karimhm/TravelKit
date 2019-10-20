/*
 *  TKStopPlace.h
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <CoreLocation/CLLocation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(StopPlace)
@interface TKStopPlace : TKItem

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) CLLocation *location;

@end

NS_ASSUME_NONNULL_END
