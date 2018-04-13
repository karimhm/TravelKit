/*
 *  TKStationIndexFunction.m
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStationIndexFunction.h"
#import "TKStructs.h"

static TKDBFunctionContext _stationIndexFunction = {NULL, 0, NULL, false, NULL, NULL, NULL, NULL};
static BOOL _didInit = false;

static void TKStationIndexFunctionExecute(TKDBContextRef context, int valuesCount, TKDBValueRef _Nonnull * _Nonnull values) {
    if (TKDBValueGetType(values[0]) == TKDBValueTypeBlob
        && TKDBValueGetType(values[1]) == TKDBValueTypeInteger)
    {
        int32_t bytes = TKDBValueGetBytes(values[0]);
        int32_t length = (bytes &~ 7) / 8;
        TKStationNode *stations = (TKStationNode*)TKDBValueGetBlob(values[0]);
        
        uint32_t stationId = TKAligned32((uint32_t)TKDBValueGetInt64(values[1]));
        
        int32_t low = 0;
        int32_t high = length;
        int32_t mid = 0;
        
        while (low < high) {
            mid = low + (high - low) / 2;
            
            if (stations[mid].stationId == stationId) {
                TKDBContextResultInt64(context, TKAligned32(stations[mid].index));
                break;
            } else if (stations[mid].stationId < stationId) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
    } else {
        TKDBContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
    }
}

TKDBFunctionContext TKGetStationIndexFunction(void) {
    if (!_didInit) {
        _stationIndexFunction.name = "tkStationIndex";
        _stationIndexFunction.valuesCount = 2;
        _stationIndexFunction.deterministic = true;
        _stationIndexFunction.execute = TKStationIndexFunctionExecute;
        
        _didInit = true;
    }
    
    return _stationIndexFunction;
}
