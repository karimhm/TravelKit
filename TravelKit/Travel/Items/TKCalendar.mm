/*
 *  TKCalendar.m
 *  Created on 15/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKCalendar.h"
#import "TKItem_Core.h"
#import "ItemID.h"

using namespace tk;

@implementation TKCalendar

-(instancetype)initWithStatement:(Ref<Statement>)statement {
    if (self = [super initWithStatement:statement]) {
        _name = [NSString stringWithUTF8String:static_cast<const char*>((*statement)["name"].stringValue().c_str())];
        _shortName = [NSString stringWithUTF8String:static_cast<const char*>((*statement)["shortName"].stringValue().c_str())];
        _days = static_cast<uint8_t>((*statement)["days"].intValue());
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    TKCalendar *calendar = [super copyWithZone:zone];
    calendar->_name = self.name;
    calendar->_shortName = self.shortName;
    calendar->_days = self.days;
    
    return calendar;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    TK_ENCODE_OBJ(aCoder, name);
    TK_ENCODE_OBJ(aCoder, shortName);
    TK_ENCODE_INTEGER(aCoder, days);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        TK_DECODE_OBJ_CLASS(aDecoder, name, NSString);
        TK_DECODE_OBJ_CLASS(aDecoder, shortName, NSString);
        TK_DECODE_INTEGER(aDecoder, days);
    }
    return self;
}

- (void)dealloc {
    _name = nil;
    _shortName = nil;
}

#ifdef DEBUG
- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p; id: %@; name: %@, shortName: %@, days: %i>", [self class], self, [NSString stringWithUTF8String:IID(self.identifier).stringID().c_str()], self.name, self.shortName, self.days];
}
#endif

@end
