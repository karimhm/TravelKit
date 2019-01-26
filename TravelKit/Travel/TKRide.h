/*
 *  TKRide.h
 *  Created on 26/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKStop.h>

@interface TKRide : NSObject

@property (readonly, nonatomic) NSArray<TKStop *> *stops;

@end
