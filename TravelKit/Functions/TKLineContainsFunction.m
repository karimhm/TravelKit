/*
 *  TKLineContainsFunction.m
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKLineContainsFunction.h"
#import "TKStructs.h"

static TKDBFunctionContext _containsFunction = {NULL, 0, NULL, false, NULL, NULL, NULL, NULL};
static BOOL _didInit = false;

static void TKLineContainsFunctionExecute(TKDBContextRef context, int valuesCount, TKDBValueRef _Nonnull * _Nonnull values) {
    if (TKDBValueGetType(values[0]) == TKDBValueTypeBlob
        && TKDBValueGetType(values[1]) == TKDBValueTypeInteger
        && TKDBValueGetType(values[2]) == TKDBValueTypeInteger)
    {
        int32_t bytes = TKDBValueGetBytes(values[0]);
        int32_t length = (bytes &~ 7) / 8;
        TKStationNode *stations = (TKStationNode*)TKDBValueGetBlob(values[0]);
        
        bool firstFound = false;
        bool secondFound = false;
        
        uint32_t first = TKAligned32((uint32_t)TKDBValueGetInt64(values[1]));
        uint32_t second = TKAligned32((uint32_t)TKDBValueGetInt64(values[2]));
        
        int32_t low = 0;
        int32_t high = length;
        int32_t mid = 0;
        
        while (low < high) {
            mid = low + (high - low) / 2;
            
            if (stations[mid].stationId == first) {
                firstFound = true;
                break;
            } else if (stations[mid].stationId < first) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        
        if (!firstFound) {
            TKDBContextResultNull(context);
            return;
        } else if (first == second) {
            TKDBContextResultInt64(context, 1);
            return;
        }
        
        low = 0;
        high = length;
        mid = 0;
        
        while (low < high) {
            mid = low + (high - low) / 2;
            
            if (stations[mid].stationId == second) {
                secondFound = true;
                break;
            } else if (stations[mid].stationId < second) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        
        if (secondFound) {
            TKDBContextResultInt64(context, 1);
        }else {
            TKDBContextResultNull(context);
        }
        
    } else {
        TKDBContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
    }
}

TKDBFunctionContext TKGetLineContainsFunction(void) {
    if (!_didInit) {
        _containsFunction.name = "tkLineContains";
        _containsFunction.valuesCount = 3;
        _containsFunction.deterministic = true;
        _containsFunction.execute = TKLineContainsFunctionExecute;
        
        _didInit = true;
    }
    
    return _containsFunction;
}
