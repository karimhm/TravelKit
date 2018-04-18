/*
 *  TKPathResponse.h
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKStation.h>
#import <TravelKit/TKDeparture.h>
#import <Foundation/Foundation.h>

@interface TKPathResponse : NSObject

@property (nonatomic, readonly) NSArray<TKDeparture *> *departures;

@property (nonatomic, readonly) TKStation *source;
@property (nonatomic, readonly) TKStation *destination;

@end
