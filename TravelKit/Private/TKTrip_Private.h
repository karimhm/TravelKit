/*
*  TKTrip_Private.h
*  Created on 18/Oct/19.
*
*  Copyright (C) 2019 Karim. All rights reserved.
*/

#import "TKTrip.h"

@interface TKTrip ()

- (void)setRoute:(TKRoute *)route;
- (void)setStopTimes:(NSArray<TKStopTime *> *)stopTimes;

@end
