/*
 *  TKStop.h
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKStation.h>
#import <Foundation/Foundation.h>

@interface TKStop : NSObject

@property (nonatomic, readonly) TKStation *station;
@property (nonatomic, readonly) NSString *localizedTime;

@end
