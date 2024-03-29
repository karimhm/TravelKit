/*
 *  TKRide.h
 *  Created on 26/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKStop.h>
#import <TravelKit/TKRoute.h>

NS_SWIFT_NAME(Ride)
@interface TKRide : NSObject <NSCopying, NSCoding, NSSecureCoding>

@property (readonly, nonatomic) NSArray<TKStop *> *stops;
@property (readonly, nonatomic) TKRoute *route;

@end
