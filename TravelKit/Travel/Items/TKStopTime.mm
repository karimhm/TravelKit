/*
 *  TKStopTime.m
 *  Created on 5/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKStopTime.h"
#import "TKTime_Private.h"
#import "TKItem_Core.h"
#import "ItemID.h"
#import "TKUtilities.h"

using namespace tk;

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
