/*
 *  TKPathResponse_Private.h
 *  Created on 13/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKPathResponse.h"

@interface TKPathResponse ()

- (instancetype)initWithDepartures:(NSArray<TKDeparture *> *)departures source:(TKStation *)source destination:(TKStation *)destination;

@end
