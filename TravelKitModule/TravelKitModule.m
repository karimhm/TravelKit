/*
 *  TravelKitModule.h
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TravelKitModule.h"
#import "TKDistanceFunction.h"
#import "TKLineContainsFunction.h"
#import "TKStationIndexFunction.h"
#import "TKDepartureWayFunction.h"
#import "TKDepartureAvailableFunction.h"
#import <sqlite3ext.h>

SQLITE_EXTENSION_INIT1

static int TKDBAddFunction(TKDBFunctionContext function, sqlite3* db) {
    return sqlite3_create_function_v2(db,
                                      function.name,
                                      function.valuesCount,
                                      function.deterministic ? (SQLITE_UTF8 | SQLITE_DETERMINISTIC) : (SQLITE_UTF8),
                                      function.info,
                                      function.execute,
                                      function.step,
                                      function.finalize,
                                      function.destroy);
}

TK_EXTERN int sqlite3_extension_init( sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi) {
    int status = SQLITE_OK;
    SQLITE_EXTENSION_INIT2(pApi);
    
    if ((status = TKDBAddFunction(TKGetDistanceFunction(), db)) != SQLITE_OK) {
        goto cleanup;
    }
    
    if ((status = TKDBAddFunction(TKGetLineContainsFunction(), db)) != SQLITE_OK) {
        goto cleanup;
    }
    
    if ((status = TKDBAddFunction(TKGetStationIndexFunction(), db)) != SQLITE_OK) {
        goto cleanup;
    }
    
    if ((status = TKDBAddFunction(TKGetDepartureWayFunction(), db)) != SQLITE_OK) {
        goto cleanup;
    }
    
    if ((status = TKDBAddFunction(TKGetDepartureAvailableFunction(), db)) != SQLITE_OK) {
        goto cleanup;
    }
    
cleanup:
    return status;
};
