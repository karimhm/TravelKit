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

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    TKStop *stop = [[[self class] allocWithZone:zone] init];
    stop->_time = self->_time;
    stop->_station = self.station;
    stop->_dateComponents = self.dateComponents;
    
    return stop;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    TK_ENCODE_INT32(aCoder, time);
    TK_ENCODE_OBJ(aCoder, station);
    TK_ENCODE_OBJ(aCoder, dateComponents);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        TK_DECODE_INT32(aDecoder, time);
        TK_DECODE_OBJ_CLASS(aDecoder, station, TKStation);
        TK_DECODE_OBJ_CLASS(aDecoder, dateComponents, NSDateComponents);
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return true;
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
