//
//  TKRoute.m
//  TravelKit
//
//  Created by Karim on 2/5/19.
//  Copyright © 2019 Karim. All rights reserved.
//

#import "TKRoute.h"
#import "TKItem_Core.h"
#import "ItemID.h"

using namespace tk;

@implementation TKRoute

-(instancetype)initWithStatement:(Ref<Statement>)statement {
    if (self = [super initWithStatement:statement]) {
        _name = [NSString stringWithUTF8String:static_cast<const char*>((*statement)["name"].stringValue().c_str())];
        
        Value description = (*statement)["description"];
        if (description.isString()) {
            _routeDescription = [NSString stringWithUTF8String:static_cast<const char*>(description.stringValue().c_str())];
        }
        
        Value color = (*statement)["color"];
        if (color.isInteger()) {
            _color = TKColorFromHexRGB(color.intValue());
        }
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    TKRoute *route = [super copyWithZone:zone];
    route->_name = self.name;
    route->_routeDescription = self.routeDescription;
    route->_color = self.color;
    
    return route;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    TK_ENCODE_OBJ(aCoder, name);
    TK_ENCODE_OBJ(aCoder, routeDescription);
    TK_ENCODE_OBJ(aCoder, color);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        TK_DECODE_OBJ_CLASS(aDecoder, name, NSString);
        TK_DECODE_OBJ_CLASS(aDecoder, routeDescription, NSString);
        TK_DECODE_OBJ_CLASS(aDecoder, color, UIColor);
    }
    return self;
}

- (void)dealloc {
    _name = nil;
    _routeDescription = nil;
    _color = nil;
}

#ifdef DEBUG
- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p; id: %@; name: %@, description: %@>", [self class], self, [NSString stringWithUTF8String:IID(self.identifier).stringID().c_str()], self.name, self.routeDescription];
}
#endif

@end
