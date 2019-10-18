/*
 *  TKQuery_Private.h
 *  Created on 19/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKQuery.h"

@interface TKQuery ()

@property (strong, nonatomic) NSString *language;

@property (nonatomic) BOOL fetchStopTimes;

@property (nonatomic, readonly) BOOL idSet;
@property (nonatomic, readonly) BOOL stopPlaceIDSet;
@property (nonatomic, readonly) BOOL routeIDSet;
@property (nonatomic, readonly) BOOL tripIDSet;

@end
