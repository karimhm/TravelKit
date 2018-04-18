/*
 *  TKPathResponse.m
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKPathResponse.h"
#import "TKPathResponse_Private.h"

@implementation TKPathResponse

- (instancetype)initWithDepartures:(NSArray<TKDeparture *> *)departures source:(TKStation *)source destination:(TKStation *)destination {
    if (self = [super init]) {
        _departures = departures;
        _source = source;
        _destination = destination;
    }
    return self;
}

- (void)dealloc {
    _departures = nil;
    _source = nil;
    _destination = nil;
}

@end
