/*
 *  TKDBFunction.h
 *  Created on 13/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKDefines.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct sqlite3_context* TKDBContextRef;
typedef struct sqlite3_value* TKDBValueRef;

TK_INLINE TKDBValueType TKDBValueGetType(TKDBValueRef value) {
    return (TKDBValueType)sqlite3_value_type(value);
}

TK_INLINE const void * TKDBValueGetBlob(TKDBValueRef value) {
    return sqlite3_value_blob(value);
}

TK_INLINE int TKDBValueGetBytes(TKDBValueRef value) {
    return sqlite3_value_bytes(value);
}

TK_INLINE double TKDBValueGetDouble(TKDBValueRef value) {
    return sqlite3_value_bytes(value);
}

TK_INLINE int64_t TKDBValueGetInt64(TKDBValueRef value) {
    return sqlite3_value_int64(value);
}

TK_INLINE const char* TKDBValueGetText(TKDBValueRef value) {
    return (const char*)sqlite3_value_text(value);
}

/*!
 @function  TKDBContextGetInfo
 
 @param     context
            The TKDBContextRef context
 
 @result    The info pinter contained in TKDBFunctionContext.
 */
TK_INLINE void* TKDBContextGetInfo(TKDBContextRef context) {
    return sqlite3_user_data(context);
}

/*!
 @function  TKDBContextResultError
 
 @param     context
            The TKDBContextRef context
 @param     name
            The name of the error. The text is expected to be encoded as UTF-8.
 @param     code
            An int representing the code of the error.
 */
TK_INLINE void TKDBContextResultError(TKDBContextRef context, const char *name, int code) {
    sqlite3_result_error(context, name, code);
}

TK_INLINE void TKDBContextResultBlob(TKDBContextRef context, const void* blob, uint64_t bytes) {
    sqlite3_result_blob64(context, blob, bytes, SQLITE_TRANSIENT);
}

TK_INLINE void TKDBContextResultConstBlob(TKDBContextRef context, const void* blob, uint64_t bytes) {
    sqlite3_result_blob64(context, blob, bytes, SQLITE_STATIC);
}

TK_INLINE void TKDBContextResultDouble(TKDBContextRef context, double val) {
    sqlite3_result_double(context, val);
}

TK_INLINE void TKDBContextResultInt64(TKDBContextRef context, int64_t val) {
    sqlite3_result_int64(context, val);
}

TK_INLINE void TKDBContextResultText(TKDBContextRef context, const char* text, uint64_t bytes) {
    sqlite3_result_text64(context, text, bytes, SQLITE_TRANSIENT, SQLITE_UTF8);
}

TK_INLINE void TKDBContextResultConstText(TKDBContextRef context, const char* text, uint64_t bytes) {
    sqlite3_result_text64(context, text, bytes, SQLITE_STATIC, SQLITE_UTF8);
}

TK_INLINE void TKDBContextResultNull(TKDBContextRef context) {
    sqlite3_result_null(context);
}

typedef void (*TKDBFunctionExecute)(TKDBContextRef context, int valuesCount, TKDBValueRef _Nonnull * _Nonnull values);
typedef void (*TKDBFunctionStep)(TKDBContextRef context, int valuesCount, TKDBValueRef _Nonnull * _Nonnull values);
typedef void (*TKDBFunctionFinalize)(TKDBContextRef context);
typedef void (*TKDBFunctionDestroy)(void *info);

/*!
 @struct TKDBFunctionContext
 
 @abstract This structure contains properties and callbacks that define an SQL function that will be added to the database.
 */
typedef struct {
    const char *name;
    int valuesCount;
    void *info;
    BOOL deterministic;
    TKDBFunctionExecute     execute;
    TKDBFunctionStep        step;
    TKDBFunctionFinalize    finalize;
    TKDBFunctionDestroy     destroy;
} TKDBFunctionContext;

NS_ASSUME_NONNULL_END
