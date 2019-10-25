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
    CLLocation *_location;
    TKItemID _stopPlaceID;
    TKItemID _routeID;
    TKItemID _tripID;
    BOOL _idSet;
    BOOL _stopPlaceIDSet;
    BOOL _routeIDSet;
    BOOL _tripIDSet;
}

- (void)setItemID:(TKItemID)itemID {
    _itemID = itemID;
    _idSet = true;
}

- (void)setLocation:(CLLocation *)location {
    _location = location;
}

- (CLLocation *)location {
    return _location;
}

- (void)setStopPlaceID:(TKItemID)stopPlaceID {
    _stopPlaceID = stopPlaceID;
    _stopPlaceIDSet = true;
}

- (TKItemID)stopPlaceID {
    return _stopPlaceID;
}

- (void)setRouteID:(TKItemID)routeID {
    _routeID = routeID;
    _routeIDSet = true;
}

- (TKItemID)routeID {
    return _routeID;
}

- (void)setTripID:(TKItemID)tripID {
    _tripID = tripID;
    _tripIDSet = true;
}

- (BOOL)idSet {
    return _idSet;
}

- (BOOL)stopPlaceIDSet {
    return _stopPlaceIDSet;
}

- (BOOL)routeIDSet {
    return _routeIDSet;
}

- (BOOL)tripIDSet {
    return _tripIDSet;
}

@end
