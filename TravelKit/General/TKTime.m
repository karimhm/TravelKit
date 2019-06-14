/*
 *  TKTime.m
 *  Created on 6/Jun/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKTime.h"
#import "TKTime_Private.h"
#import "TKDefines_Private.h"
#import "TKUtilities.h"

@implementation TKTime

- (instancetype)initWithTimeInterval:(NSTimeInterval)time {
    if (self = [super init]) {
        TKTimeInfo timeInfo = TKTimeInfoCreate(time);
        
        _second = timeInfo.second;
        _minute = timeInfo.minute;
        _hour = timeInfo.hour;
        _day = timeInfo.day;
        
        _dateComponents = [[NSDateComponents alloc] init];
        _dateComponents.second = timeInfo.second;
        _dateComponents.minute = timeInfo.minute;
        _dateComponents.hour = timeInfo.hour;
        _dateComponents.day = timeInfo.day;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object != nil && [object class] == [self class]) {
        TKTime *other = object;
        
        return self.second == other.second
        && self.minute == other.minute
        && self.hour == other.hour
        && self.day == other.day;
    } else {
        return false;
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    TKTime *time = [[[self class] allocWithZone:zone] init];
    time->_second = self.second;
    time->_minute = self.minute;
    time->_hour = self.hour;
    time->_day = self.day;
    
    return time;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    TK_ENCODE_INTEGER(aCoder, second);
    TK_ENCODE_INTEGER(aCoder, minute);
    TK_ENCODE_INTEGER(aCoder, hour);
    TK_ENCODE_INTEGER(aCoder, day);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        TK_DECODE_INTEGER(aDecoder, second);
        TK_DECODE_INTEGER(aDecoder, minute);
        TK_DECODE_INTEGER(aDecoder, hour);
        TK_DECODE_INTEGER(aDecoder, day);
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return true;
}

@end
