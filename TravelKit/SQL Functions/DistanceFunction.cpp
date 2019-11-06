/*
 *  TKDistanceFunction.m
 *  Created on 10/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#include "DistanceFunction.h"
#include "Coordinate2D.h"

using namespace tk;

TK_ALWAYS_INLINE double _Distance(double lat1, double lon1, double lat2, double lon2) {
    return Coordinate2D(lat1, lon1).distance({lat2, lon2});
}

static FunctionContext _distanceFunction = FunctionContext::Empty();
static bool _didInit = false;

static void DistanceFunctionExecute(ContextRef context, int valuesCount, ValueRef* values) {
    if (valuesCount == 4) {
        if (ValueGetType(values[0]) != ValueType::Float
            || ValueGetType(values[1]) != ValueType::Float
            || ValueGetType(values[2]) != ValueType::Float
            || ValueGetType(values[3]) != ValueType::Float)
        {
            ContextResultError(context, "arguments type mismatch", SQLITE_MISMATCH);
            return;
        }
        
        ContextResultDouble(context, _Distance(ValueGetDouble(values[0]),
                                               ValueGetDouble(values[1]),
                                               ValueGetDouble(values[2]),
                                               ValueGetDouble(values[3])));
    } else {
        ContextResultError(context, "wrong number of arguments to function tkDistance()", SQLITE_MISUSE);
    }
}

FunctionContext SQLite::GetDistanceFunction(void) {
    if (!_didInit) {
        _distanceFunction.name = "tkDistance";
        _distanceFunction.valuesCount = 4;
        _distanceFunction.deterministic = true;
        _distanceFunction.execute = DistanceFunctionExecute;
        
        _didInit = true;
    }
    
    return _distanceFunction;
}
