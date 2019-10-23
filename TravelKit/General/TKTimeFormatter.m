/*
 *  TKTimeFormatter.m
 *  Created on 5/Jun/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKTimeFormatter.h"
#import "TKTime_Private.h"

@implementation TKTimeFormatter {
    NSCalendar *_calendar;
    NSDateFormatter *_dateFormatter;
}

+ (instancetype)shared {
    static TKTimeFormatter *_shared = nil;
    static dispatch_once_t _once;
    
    dispatch_once(&_once, ^{
        _shared = [[[self class] alloc] init];
    });
    
    return _shared;
}

- (instancetype)init {
    if (self = [super init]) {
        _calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.calendar = _calendar;
        _dateFormatter.dateStyle = NSDateFormatterNoStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return self;
}

- (NSString *)stringFromTime:(TKTime *)time {
    NSDate *date = [_calendar dateFromComponents:time.dateComponents];
    if (date) {
        return [_dateFormatter stringFromDate:date];
    } else {
        return nil;
    }
}

- (NSString *)stringForObjectValue:(id)obj {
    if ([obj isKindOfClass:[TKTime class]]) {
        return [self stringFromTime:obj];
    } else {
        return nil;
    }
}

+ (NSString *)localizedStringFromTime:(TKTime *)time {
    return [[self shared] stringFromTime:time];
}

@end
