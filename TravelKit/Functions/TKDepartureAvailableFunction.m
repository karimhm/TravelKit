/*
 *  TKDepartureAvailableFunction.m
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDepartureAvailableFunction.h"

static TKDBFunctionContext _departureAvailableFunction = {NULL, 0, NULL, false, NULL, NULL, NULL, NULL};
static BOOL _didInit = false;

static void TKDepartureAvailableExecute(TKDBContextRef context, int valuesCount, TKDBValueRef _Nonnull * _Nonnull values) {
    if (TKDBValueGetType(values[0]) == TKDBValueTypeBlob
        && TKDBValueGetType(values[1]) == TKDBValueTypeInteger
        && TKDBValueGetType(values[2]) == TKDBValueTypeInteger
        && TKDBValueGetType(values[3]) == TKDBValueTypeInteger)
    {
        int32_t bytes = TKDBValueGetBytes(values[0]);
        int32_t length = (bytes &~ 3) / 4;
        
        int32_t* stops = (int32_t*)TKDBValueGetBlob(values[0]);
        int32_t departureTime = (int32_t)TKDBValueGetInt64(values[1]);
        int32_t departureIndex = (int32_t)TKDBValueGetInt64(values[2]);
        int32_t arrivalIndex = (int32_t)TKDBValueGetInt64(values[3]);
        
        if (departureIndex >= length || arrivalIndex >= length) {
            TKDBContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
        } else if (stops[arrivalIndex] != -1 && (stops[departureIndex] >= departureTime)) {
            TKDBContextResultInt64(context, stops[departureIndex]);
        } else {
            TKDBContextResultNull(context);
        }
    } else {
        TKDBContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
    }
}

TK_EXTERN TKDBFunctionContext TKGetDepartureAvailableFunction(void) {
    if (!_didInit) {
        _departureAvailableFunction.name = "tkDepartureAvailable";
        _departureAvailableFunction.valuesCount = 4;
        _departureAvailableFunction.deterministic = true;
        _departureAvailableFunction.execute = TKDepartureAvailableExecute;
        
        _didInit = true;
    }
    
    return _departureAvailableFunction;
}
