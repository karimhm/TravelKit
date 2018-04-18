/*
 *  TKDeparture.h
 *  Created on 28/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <TravelKit/TKStop.h>

typedef NS_ENUM(NSInteger, TKWay) {
    TKWayForward = 1,
    TKWayBackward
};

@interface TKDeparture : TKItem

@property (nonatomic, readonly) TKWay way;
@property (nonatomic, readonly) NSArray <TKStop *> *stops;

@end
