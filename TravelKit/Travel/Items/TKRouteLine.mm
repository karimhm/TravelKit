/*
 *  TKRouteLine.mm
 *  Created on 20/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKRouteLine.h"
#import "TKItem_Core.h"

@implementation TKRouteLine

- (instancetype)initWithStatement:(tk::Ref<tk::Statement>)statement {
    if (self = [super initWithStatement:statement]) {
        TKTravelDirection direction = (*statement)["direction"].int64Value();
        
        if (direction != TKTravelDirectionOutbound && direction != TKTravelDirectionInbound) {
            direction = TKTravelDirectionUnknown;
        }
        
        _direction = direction;
    }
    return self;
}

- (void)setRoute:(TKRoute *)route {
    _route = route;
}

- (void)setStopPlaces:(NSArray<TKStopPlace *> *)stopPlaces {
    _stopPlaces = stopPlaces;
}

- (void)dealloc {
    _route = nil;
    _stopPlaces = nil;
}

@end
