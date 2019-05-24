/*
 *  TKRouteLine.mm
 *  Created on 20/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKRouteLine.h"
#import "TKItem_Core.h"

@implementation TKRouteLine

- (void)setRoute:(TKRoute *)route {
    _route = route;
}

- (void)setOutboundStopPlaces:(NSArray<TKStopPlace *> *)outboundStopPlaces {
    _outboundStopPlaces = outboundStopPlaces;
}

- (void)setInboundStopPlaces:(NSArray<TKStopPlace *> *)inboundStopPlaces {
    _inboundStopPlaces = inboundStopPlaces;
}

- (void)dealloc {
    _route = nil;
    _outboundStopPlaces = nil;
    _inboundStopPlaces = nil;
}

@end
