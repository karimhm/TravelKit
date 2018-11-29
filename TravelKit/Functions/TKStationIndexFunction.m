/*
 *  TKStationIndexFunction.m
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStationIndexFunction.h"
#import "TKStructs.h"

static DBKFunctionContext _stationIndexFunction = {NULL, 0, NULL, false, NULL, NULL, NULL, NULL};
static BOOL _didInit = false;

static void TKStationIndexFunctionExecute(DBKContextRef context, int valuesCount, DBKValueRef _Nonnull * _Nonnull values) {
    if (DBKValueGetType(values[0]) == DBKValueTypeBlob
        && DBKValueGetType(values[1]) == DBKValueTypeInteger)
    {
        int32_t bytes = DBKValueGetBytes(values[0]);
        int32_t length = (bytes &~ 7) >> 3;
        TKStationNode *stations = (TKStationNode*)DBKValueGetBlob(values[0]);
        
        uint32_t stationId = TKAligned32((uint32_t)DBKValueGetInt64(values[1]));
        
        int32_t low = 0;
        int32_t high = length;
        int32_t mid = 0;
        
        while (low < high) {
            mid = low + (high - low) / 2;
            
            if (stations[mid].stationId == stationId) {
                DBKContextResultInt64(context, TKAligned32(stations[mid].index));
                return;
                break;
            } else if (stations[mid].stationId < stationId) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        
        DBKContextResultNull(context);
    } else {
        DBKContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
    }
}

DBKFunctionContext TKGetStationIndexFunction(void) {
    if (!_didInit) {
        _stationIndexFunction.name = "tkStationIndex";
        _stationIndexFunction.valuesCount = 2;
        _stationIndexFunction.deterministic = true;
        _stationIndexFunction.execute = TKStationIndexFunctionExecute;
        
        _didInit = true;
    }
    
    return _stationIndexFunction;
}
