/*
 *  TKRouteLine_Private.h
 *  Created on 20/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKRouteLine.h"

@interface TKRouteLine ()

- (instancetype)initWithStatement:(tk::Ref<tk::Statement>)statement stopPlaces:(NSArray<TKStopPlace *> *)stopPlaces routeID:(TKItemID)routeID direction:(TKTravelDirection)direction;

- (void)setStopPlaces:(NSArray<TKStopPlace *> *)stopPlaces;

@end
