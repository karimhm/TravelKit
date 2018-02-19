/*
 *  TKStation.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <CoreLocation/CLLocation.h>

@interface TKStation : TKItem

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) CLLocation *location;

@end
