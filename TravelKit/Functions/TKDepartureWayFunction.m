/*
 *  TKDepartureWayFunction.m
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDepartureWayFunction.h"

static TKDBFunctionContext _departureWayFunction = {NULL, 0, NULL, false, NULL, NULL, NULL, NULL};
static BOOL _didInit = false;

static void TKStationIndexFunctionExecute(TKDBContextRef context, int valuesCount, TKDBValueRef _Nonnull * _Nonnull values) {
    if (TKDBValueGetType(values[0]) == TKDBValueTypeInteger
        && TKDBValueGetType(values[1]) == TKDBValueTypeInteger)
    {
        int64_t first = TKDBValueGetInt64(values[0]);
        int64_t second = TKDBValueGetInt64(values[1]);
        
        TKDBContextResultInt64(context, (first < second) ? 0 : ((first > second) ? 1 : 2));
    } else {
        TKDBContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
    }
    
}

TK_EXTERN TKDBFunctionContext TKGetDepartureWayFunction(void) {
    if (!_didInit) {
        _departureWayFunction.name = "tkDepartureWay";
        _departureWayFunction.valuesCount = 2;
        _departureWayFunction.deterministic = true;
        _departureWayFunction.execute = TKStationIndexFunctionExecute;
        
        _didInit = true;
    }
    
    return _departureWayFunction;
}
