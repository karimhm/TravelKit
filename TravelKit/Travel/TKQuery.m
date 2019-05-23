/*
 *  TKQuery.m
 *  Created on 19/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKQuery.h"
#import "TKQuery_Private.h"

TKOrderProperty const TKOrderByName = @"name";

@implementation TKQuery {
    NSString *_language;
    CLLocation *_location;
    TKTravelDirection _direction;
    TKItemID _routeID;
    BOOL _idSet;
    BOOL _routeIDSet;
}

- (void)setItemID:(TKItemID)itemID {
    _itemID = itemID;
    _idSet = true;
}

- (void)setLanguage:(NSString *)language {
    _language = language;
}

- (NSString *)language {
    return _language;
}

- (void)setLocation:(CLLocation *)location {
    _location = location;
}

- (CLLocation *)location {
    return _location;
}

- (void)setDirection:(TKTravelDirection)direction {
    _direction = direction;
}

- (TKTravelDirection)direction {
    return _direction;
}

- (void)setRouteID:(TKItemID)routeID {
    _routeID = routeID;
    _routeIDSet = true;
}

- (TKItemID)routeID {
    return _routeID;
}

- (BOOL)idSet {
    return _idSet;
}

- (BOOL)routeIDSet {
    return _routeIDSet;
}

@end
