/*
 *  TKMatchFunction.m
 *  Created on 5/May/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKMatchFunction.h"

static DBKFunctionContext _matchFunction = {NULL, 0, NULL, false, NULL, NULL, NULL, NULL};
static BOOL _didInit = false;

static void TKMatchFunctionExecute(DBKContextRef context, int valuesCount, DBKValueRef _Nonnull * _Nonnull values) {
    if (DBKValueGetType(values[0]) == DBKValueTypeInteger
        && DBKValueGetType(values[1]) == DBKValueTypeBlob)
    {
        int32_t toMatch = (int32_t)DBKValueGetInt64(values[0]);
        int32_t bytes = DBKValueGetBytes(values[1]);
        int32_t length = (bytes &~ 3) >> 2;
        int32_t* ids = (int32_t*)DBKValueGetBlob(values[1]);
        
        int32_t low = 0;
        int32_t high = length;
        int32_t mid = 0;
        
        while (low < high) {
            mid = low + (high - low) / 2;
            if (ids[mid] == toMatch) {
                return DBKContextResultInt64(context, 1);
            } else if (ids[mid] < toMatch) {
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

TK_EXTERN DBKFunctionContext TKGetMatchFunction(void) {
    if (!_didInit) {
        _matchFunction.name = "tkMatch";
        _matchFunction.valuesCount = 2;
        _matchFunction.deterministic = true;
        _matchFunction.execute = TKMatchFunctionExecute;
        
        _didInit = true;
    }
    
    return _matchFunction;
}
