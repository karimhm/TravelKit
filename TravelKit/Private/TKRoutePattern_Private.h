/*
 *  TKRoutePattern_Private.h
 *  Created on 20/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKRoutePattern.h"

@interface TKRoutePattern ()

- (void)setRoute:(TKRoute *)route;
- (void)setOutboundStopPlaces:(NSArray<TKStopPlace *> *)outboundStopPlaces;
- (void)setInboundStopPlaces:(NSArray<TKStopPlace *> *)inboundStopPlaces;

@end
