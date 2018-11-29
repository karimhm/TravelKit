/*
 *  TKDepartureAvailableFunction.m
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDepartureAvailableFunction.h"
#import "TKStop.h"

static DBKFunctionContext _departureAvailableFunction = {NULL, 0, NULL, false, NULL, NULL, NULL, NULL};
static BOOL _didInit = false;

static void TKDepartureAvailableExecute(DBKContextRef context, int valuesCount, DBKValueRef _Nonnull * _Nonnull values) {
    if (DBKValueGetType(values[0]) == DBKValueTypeBlob
        && DBKValueGetType(values[1]) == DBKValueTypeInteger
        && DBKValueGetType(values[2]) == DBKValueTypeInteger
        && DBKValueGetType(values[3]) == DBKValueTypeInteger)
    {
        int32_t bytes = DBKValueGetBytes(values[0]);
        int32_t length = (bytes &~ 3) >> 2;
        
        int32_t* stops = (int32_t*)DBKValueGetBlob(values[0]);
        int32_t departureTime = (int32_t)DBKValueGetInt64(values[1]);
        int32_t departureIndex = (int32_t)DBKValueGetInt64(values[2]);
        int32_t arrivalIndex = (int32_t)DBKValueGetInt64(values[3]);
        
        if (departureIndex >= length || arrivalIndex >= length) {
            DBKContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
        } else if ((int32_t)TKAligned32(stops[arrivalIndex]) >= 0
                   && (int32_t)TKAligned32(stops[departureIndex]) >= 0
                   && (TKAligned32(stops[departureIndex]) >= departureTime))
        {
            DBKContextResultInt64(context, stops[departureIndex]);
        } else {
            DBKContextResultNull(context);
        }
    } else {
        DBKContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
    }
}

TK_EXTERN DBKFunctionContext TKGetDepartureAvailableFunction(void) {
    if (!_didInit) {
        _departureAvailableFunction.name = "tkDepartureAvailable";
        _departureAvailableFunction.valuesCount = 4;
        _departureAvailableFunction.deterministic = true;
        _departureAvailableFunction.execute = TKDepartureAvailableExecute;
        
        _didInit = true;
    }
    
    return _departureAvailableFunction;
}
