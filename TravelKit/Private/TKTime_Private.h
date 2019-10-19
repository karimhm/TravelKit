/*
 *  TKTime_Private.h
 *  Created on 4/Jun/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKStopTime.h"

@interface TKTime ()

- (instancetype)initWithTimeInterval:(NSTimeInterval)time;

@property (nonatomic, readonly) NSDateComponents *dateComponents;

@end
