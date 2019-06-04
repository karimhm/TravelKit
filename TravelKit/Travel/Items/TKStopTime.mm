/*
 *  TKStopTime.m
 *  Created on 5/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKStopTime.h"
#import "TKItem_Core.h"
#import "ItemID.h"
#import "TKUtilities.h"

using namespace tk;

@implementation TKTime

- (instancetype)initWithTimeInterval:(NSTimeInterval)time {
    if (self = [super init]) {
        TKTimeInfo timeInfo = TKTimeInfoCreate(time);
        
        _second = timeInfo.second;
        _minute = timeInfo.minute;
        _hour = timeInfo.hour;
        _day = timeInfo.day;
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

@implementation TKStopTime

-(instancetype)initWithStatement:(Ref<Statement>)statement {
    if (self = [super initWithStatement:statement]) {
        _arrival = [[TKTime alloc] initWithTimeInterval:(*statement)["arrivalTime"].doubleValue()];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    TKStopTime *stopTime = [super copyWithZone:zone];
    stopTime->_stopPlace = self.stopPlace;
    stopTime->_arrival = self.arrival;
    stopTime->_calendar = self.calendar;
    
    return stopTime;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    TK_ENCODE_OBJ(aCoder, stopPlace);
    TK_ENCODE_OBJ(aCoder, arrival);
    TK_ENCODE_OBJ(aCoder, calendar);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        TK_DECODE_OBJ_CLASS(aDecoder, stopPlace, TKStopPlace);
        TK_DECODE_OBJ_CLASS(aDecoder, arrival, TKTime);
        TK_DECODE_OBJ_CLASS(aDecoder, calendar, TKCalendar);
    }
    return self;
}

- (void)setStopPlace:(TKStopPlace *)stopPlace {
    _stopPlace = stopPlace;
}

- (void)setCalendar:(TKCalendar *)calendar {
    _calendar = calendar;
}

- (void)dealloc {
    _stopPlace = nil;
    _arrival = nil;
    _calendar = nil;
}

#ifdef DEBUG
- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p; id: %@; arrival: %li:%li>", [self class], self, [NSString stringWithUTF8String:IID(self.identifier).stringID().c_str()], (long)self.arrival.hour, (long)self.arrival.minute];
}
#endif

@end
