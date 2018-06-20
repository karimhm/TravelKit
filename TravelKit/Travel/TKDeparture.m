/*
 *  TKDeparture.m
 *  Created on 28/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDeparture.h"
#import "TKStructs.h"
#import "TKItem_Private.h"
#import "TKStop_Private.h"

TK_ALWAYS_INLINE int32_t TKAdjustedIndex(int32_t index, int32_t length) {
    return (length - 1) - index;
}

@implementation TKDeparture
@synthesize valid = _valid;

- (instancetype)initWithRow:(id <TKDBRow>)row manager:(id <TKItemManager>)manager {
    if (self = [super initWithRow:row manager:manager]) {
        _way = [row int64ForColumn:kTKColumnWay] ? TKWayBackward:TKWayForward;
        _available = ([row int64ForColumn:kTKColumnAvailable] != 0);
        
        int32_t spLength = ([row bytesForColumn:kTKColumnStops] &~ 3) >> 2;
        int32_t stLength = ([row bytesForColumn:kTKColumnStations] &~ 7) >> 3;
        int32_t way = (int32_t)[row int64ForColumn:kTKColumnWay];
        int32_t* stops = (int32_t*)[row blobForColumn:kTKColumnStops];
        TKStationNode* stations = (TKStationNode*)[row blobForColumn:kTKColumnStations];
        
        int32_t sIndex = (int32_t)[row int64ForColumn:kTKColumnSIndex];
        int32_t dIndex = (int32_t)[row int64ForColumn:kTKColumnDIndex];
        
        if (sIndex >= stLength || dIndex >= stLength) {
            _valid = false;
            return nil;
        }
        
        NSMutableArray *stopsArray = [[NSMutableArray alloc] initWithCapacity:spLength];
        
        if (way == 0) {
            for (int32_t i = sIndex; i <= dIndex; i++) {
                int32_t hours = TKAligned32(stops[i]);
                
                if (hours >= 0) {
                    TKStation *station = [manager itemWithIdentifier:TKAligned32(stations[i].stationId) table:kTKTableStation error:nil];
                    TKStop *stop = [TKStop stopWithStation:station time:hours];
                    [stopsArray addObject:stop];
                }
            }
        } else {
            for (int32_t i = TKAdjustedIndex(sIndex, spLength); i <= TKAdjustedIndex(dIndex, spLength); i++) {
                int32_t hours = TKAligned32(stops[TKAdjustedIndex(i, spLength)]);
                
                if (hours >= 0) {
                    TKStation *station = [manager itemWithIdentifier:TKAligned32(stations[TKAdjustedIndex(i, spLength)].stationId) table:kTKTableStation error:nil];
                    TKStop *stop = [TKStop stopWithStation:station time:hours];
                    [stopsArray addObject:stop];
                }
            }
        }
        
        _stops = stopsArray;
    }
    
    return self;
}

- (NSString *)tableName {
    return kTKTableDeparture;
}

#pragma mark - TKDBVerify

+ (TKDBVerifySet *)requiredTablesAndColumns {
    return @{kTKTableDeparture:@[kTKColumnStops,
                                 kTKColumnWay,
                                 kTKColumnLineID,
                                 kTKColumnAvailabilityID,
                                 kTKColumnTrainID]
            };
}

#pragma mark -

- (void)dealloc {
    _stops = nil;
}

@end
