/*
 *  TKStop.m
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStop.h"

@implementation TKStop
@synthesize localizedTime = _localizedTime;

+ (instancetype)stopWithStation:(TKStation *)station time:(TKTimeInfo)time {
    TKStop *stop = [TKStop new];
    stop.station = station;
    stop.time = time;
    
    return stop;
}

- (void)setStation:(TKStation *)station {
    _station = station;
}

- (void)setTime:(TKTimeInfo)time {
    _time = time;
}

- (NSString *)localizedTime {
    if (!_localizedTime) {
        _localizedTime = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:(_time.hour * 3600) + (_time.minute * 60)]
                                                        dateStyle:NSDateFormatterNoStyle
                                                        timeStyle:NSDateFormatterShortStyle];
    }
    
    return _localizedTime;
}

- (void)dealloc {
    _localizedTime = nil;
    _station = nil;
}

@end
