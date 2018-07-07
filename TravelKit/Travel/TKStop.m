/*
 *  TKStop.m
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStop.h"
#import "NSDateComponents+TravelKit.h"

@implementation TKStop {
    int32_t _time;
}

+ (instancetype)stopWithStation:(TKStation *)station time:(int32_t)time {
    TKStop *stop = [TKStop new];
    stop->_station = station;
    stop->_time = time;
    stop->_dateComponents = [NSDateComponents tk_dateComponentsWithTime:time];
    
    return stop;
}

- (void)dealloc {
    _station = nil;
}

@end
