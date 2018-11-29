/*
 *  DBKFunction.h
 *  Created on 13/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <DBKit/DBKDefines.h>
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct sqlite3_context* DBKContextRef;
typedef struct sqlite3_value* DBKValueRef;

DBK_ALWAYS_INLINE DBKValueType DBKValueGetType(DBKValueRef value) {
    return (DBKValueType)sqlite3_value_type(value);
}

DBK_ALWAYS_INLINE const void * DBKValueGetBlob(DBKValueRef value) {
    return sqlite3_value_blob(value);
}

DBK_ALWAYS_INLINE int DBKValueGetBytes(DBKValueRef value) {
    return sqlite3_value_bytes(value);
}

DBK_ALWAYS_INLINE double DBKValueGetDouble(DBKValueRef value) {
    return sqlite3_value_double(value);
}

DBK_ALWAYS_INLINE int64_t DBKValueGetInt64(DBKValueRef value) {
    return sqlite3_value_int64(value);
}

DBK_ALWAYS_INLINE const char* DBKValueGetText(DBKValueRef value) {
    return (const char*)sqlite3_value_text(value);
}

/*!
 @function  DBKContextGetInfo
 
 @param     context
            The DBKContextRef context
 
 @result    The info pinter contained in DBKFunctionContext.
 */
DBK_ALWAYS_INLINE void* DBKContextGetInfo(DBKContextRef context) {
    return sqlite3_user_data(context);
}

/*!
 @function  DBKContextResultError
 
 @param     context
            The DBKContextRef context
 @param     name
            The name of the error. The text is expected to be encoded as UTF-8.
 @param     code
            An int representing the code of the error.
 */
DBK_ALWAYS_INLINE void DBKContextResultError(DBKContextRef context, const char *name, int code) {
    sqlite3_result_error(context, name, code);
}

DBK_ALWAYS_INLINE void DBKContextResultBlob(DBKContextRef context, const void* blob, uint64_t bytes) {
    sqlite3_result_blob64(context, blob, bytes, SQLITE_TRANSIENT);
}

DBK_ALWAYS_INLINE void DBKContextResultConstBlob(DBKContextRef context, const void* blob, uint64_t bytes) {
    sqlite3_result_blob64(context, blob, bytes, SQLITE_STATIC);
}

DBK_ALWAYS_INLINE void DBKContextResultDouble(DBKContextRef context, double val) {
    sqlite3_result_double(context, val);
}

DBK_ALWAYS_INLINE void DBKContextResultInt(DBKContextRef context, int val) {
    sqlite3_result_int(context, val);
}

DBK_ALWAYS_INLINE void DBKContextResultInt64(DBKContextRef context, int64_t val) {
    sqlite3_result_int64(context, val);
}

DBK_ALWAYS_INLINE void DBKContextResultText(DBKContextRef context, const char* text, uint64_t bytes) {
    sqlite3_result_text64(context, text, bytes, SQLITE_TRANSIENT, SQLITE_UTF8);
}

DBK_ALWAYS_INLINE void DBKContextResultConstText(DBKContextRef context, const char* text, uint64_t bytes) {
    sqlite3_result_text64(context, text, bytes, SQLITE_STATIC, SQLITE_UTF8);
}

DBK_ALWAYS_INLINE void DBKContextResultNull(DBKContextRef context) {
    sqlite3_result_null(context);
}

typedef void (*DBKFunctionExecute)(DBKContextRef context, int valuesCount, DBKValueRef _Nonnull * _Nonnull values);
typedef void (*DBKFunctionStep)(DBKContextRef context, int valuesCount, DBKValueRef _Nonnull * _Nonnull values);
typedef void (*DBKFunctionFinalize)(DBKContextRef context);
typedef void (*DBKFunctionDestroy)(void *info);

/*!
 @struct DBKFunctionContext
 
 @abstract This structure contains properties and callbacks that define an SQL function that will be added to the database.
 */
typedef struct {
    const char *name;
    int valuesCount;
    void *info;
    BOOL deterministic;
    DBKFunctionExecute     execute;
    DBKFunctionStep        step;
    DBKFunctionFinalize    finalize;
    DBKFunctionDestroy     destroy;
} DBKFunctionContext;

NS_ASSUME_NONNULL_END
