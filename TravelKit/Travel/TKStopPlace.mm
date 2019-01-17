/*
 *  TKStopPlace.mm
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStopPlace.h"
#import "TKItem_Core.h"
#import "ItemID.h"

using namespace tk;

@implementation TKStopPlace

-(instancetype)initWithStatement:(Ref<Statement>)statement {
    if (self = [super initWithStatement:statement]) {
        _name = [NSString stringWithUTF8String:static_cast<const char*>((*statement)["name"].stringValue().c_str())];
        _location = [[CLLocation alloc] initWithLatitude:(*statement)["latitude"].doubleValue() longitude:(*statement)["longitude"].doubleValue()];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    TKStopPlace *stopPlace = [super copyWithZone:zone];
    stopPlace->_name = self.name;
    stopPlace->_location = self.location;
    
    return stopPlace;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    TK_ENCODE_OBJ(aCoder, name);
    TK_ENCODE_OBJ(aCoder, location);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        TK_DECODE_OBJ_CLASS(aDecoder, name, NSString);
        TK_DECODE_OBJ_CLASS(aDecoder, location, CLLocation);
    }
    return self;
}

- (void)dealloc {
    _name = nil;
    _location = nil;
}

#ifdef DEBUG
- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p; id: %@; name: %@ latitude: %f, longitude: %f>", [self class], self, [NSString stringWithUTF8String:IID(self.identifier).stringID().c_str()], self.name, self.location.coordinate.latitude, self.location.coordinate.longitude];
}
#endif

@end
