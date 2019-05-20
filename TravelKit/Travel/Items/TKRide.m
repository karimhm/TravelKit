/*
 *  TKRide.m
 *  Created on 26/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKRide.h"
#import "TKRide_Private.h"

@implementation TKRide

- (instancetype)initWithStops:(NSArray<TKStop *> *)stops route:(TKRoute *)route {
    if (self = [super init]) {
        _stops = stops;
        _route = route;
    }
    return self;
}

- (void)dealloc {
    _stops = nil;
    _route = nil;
}

@end
