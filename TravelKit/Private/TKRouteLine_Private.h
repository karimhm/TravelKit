/*
 *  TKRouteLine_Private.h
 *  Created on 20/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKRouteLine.h"

@interface TKRouteLine ()

- (void)setRoute:(TKRoute *)route;
- (void)setOutboundStopPlaces:(NSArray<TKStopPlace *> *)outboundStopPlaces;
- (void)setInboundStopPlaces:(NSArray<TKStopPlace *> *)inboundStopPlaces;

@end
