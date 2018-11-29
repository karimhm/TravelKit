/*
 *  TKDepartureWayFunction.m
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDepartureWayFunction.h"

static DBKFunctionContext _departureWayFunction = {NULL, 0, NULL, false, NULL, NULL, NULL, NULL};
static BOOL _didInit = false;

static void TKStationIndexFunctionExecute(DBKContextRef context, int valuesCount, DBKValueRef _Nonnull * _Nonnull values) {
    if (DBKValueGetType(values[0]) == DBKValueTypeInteger
        && DBKValueGetType(values[1]) == DBKValueTypeInteger)
    {
        int64_t first = DBKValueGetInt64(values[0]);
        int64_t second = DBKValueGetInt64(values[1]);
        
        DBKContextResultInt64(context, (first < second) ? 0 : ((first > second) ? 1 : 2));
    } else {
        DBKContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
    }
    
}

TK_EXTERN DBKFunctionContext TKGetDepartureWayFunction(void) {
    if (!_didInit) {
        _departureWayFunction.name = "tkDepartureWay";
        _departureWayFunction.valuesCount = 2;
        _departureWayFunction.deterministic = true;
        _departureWayFunction.execute = TKStationIndexFunctionExecute;
        
        _didInit = true;
    }
    
    return _departureWayFunction;
}
