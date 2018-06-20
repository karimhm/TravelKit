/*
 *  TKMatchFunction.m
 *  Created on 5/May/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKMatchFunction.h"

static TKDBFunctionContext _matchFunction = {NULL, 0, NULL, false, NULL, NULL, NULL, NULL};
static BOOL _didInit = false;

static void TKMatchFunctionExecute(TKDBContextRef context, int valuesCount, TKDBValueRef _Nonnull * _Nonnull values) {
    if (TKDBValueGetType(values[0]) == TKDBValueTypeInteger
        && TKDBValueGetType(values[1]) == TKDBValueTypeBlob)
    {
        int32_t toMatch = (int32_t)TKDBValueGetInt64(values[0]);
        int32_t bytes = TKDBValueGetBytes(values[1]);
        int32_t length = (bytes &~ 3) >> 2;
        int32_t* ids = (int32_t*)TKDBValueGetBlob(values[1]);
        
        int32_t low = 0;
        int32_t high = length;
        int32_t mid = 0;
        
        while (low < high) {
            mid = low + (high - low) / 2;
            if (ids[mid] == toMatch) {
                return TKDBContextResultInt64(context, 1);
            } else if (ids[mid] < toMatch) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        
        TKDBContextResultNull(context);
    } else {
        TKDBContextResultError(context, "Bad parameters", SQLITE_MISMATCH);
    }
}

TK_EXTERN TKDBFunctionContext TKGetMatchFunction(void) {
    if (!_didInit) {
        _matchFunction.name = "tkMatch";
        _matchFunction.valuesCount = 2;
        _matchFunction.deterministic = true;
        _matchFunction.execute = TKMatchFunctionExecute;
        
        _didInit = true;
    }
    
    return _matchFunction;
}
