/*
 *  FunctionContext.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_FUNCTION_CONTEXT_H
#define TK_FUNCTION_CONTEXT_H

#include "Defines.h"
#include "Value.h"
#include <sqlite3.h>
#include <unistd.h>

TK_ASSUME_NONNULL_BEGIN

namespace tk {

typedef struct sqlite3_context* ContextRef;
typedef struct sqlite3_value* ValueRef;

TK_ALWAYS_INLINE ValueType ValueGetType(ValueRef value) {
    return static_cast<ValueType>(sqlite3_value_type(value));
}

TK_ALWAYS_INLINE const void * ValueGetBlob(ValueRef value) {
    return sqlite3_value_blob(value);
}

TK_ALWAYS_INLINE int ValueGetBytes(ValueRef value) {
    return sqlite3_value_bytes(value);
}

TK_ALWAYS_INLINE double ValueGetDouble(ValueRef value) {
    return sqlite3_value_double(value);
}

TK_ALWAYS_INLINE int64_t ValueGetInt64(ValueRef value) {
    return sqlite3_value_int64(value);
}

TK_ALWAYS_INLINE const char* ValueGetText(ValueRef value) {
    return (const char*)sqlite3_value_text(value);
}

/*!
 @function  TKDBContextGetInfo
 
 @param     context
 The ContextRef context
 
 @result    The info pinter contained in TKDBFunctionContext.
 */
TK_ALWAYS_INLINE void* ContextGetInfo(ContextRef context) {
    return sqlite3_user_data(context);
}

/*!
 @function  TKDBContextResultError
 
 @param     context
 The ContextRef context
 
 @param     name
 The name of the error. The text is expected to be encoded as UTF-8.
 
 @param     code
 An int representing the code of the error.
 */
TK_ALWAYS_INLINE void ContextResultError(ContextRef context, const char *name, int code) {
    sqlite3_result_error(context, name, code);
}

TK_ALWAYS_INLINE void ContextResultBlob(ContextRef context, const void* blob, uint64_t bytes) {
    sqlite3_result_blob64(context, blob, bytes, SQLITE_TRANSIENT);
}

TK_ALWAYS_INLINE void ContextResultConstBlob(ContextRef context, const void* blob, uint64_t bytes) {
    sqlite3_result_blob64(context, blob, bytes, SQLITE_STATIC);
}

TK_ALWAYS_INLINE void ContextResultDouble(ContextRef context, double val) {
    sqlite3_result_double(context, val);
}

TK_ALWAYS_INLINE void ContextResultInt(ContextRef context, int val) {
    sqlite3_result_int(context, val);
}

TK_ALWAYS_INLINE void ContextResultInt64(ContextRef context, int64_t val) {
    sqlite3_result_int64(context, val);
}

TK_ALWAYS_INLINE void ContextResultText(ContextRef context, const char* text, uint64_t bytes) {
    sqlite3_result_text64(context, text, bytes, SQLITE_TRANSIENT, SQLITE_UTF8);
}

TK_ALWAYS_INLINE void ContextResultConstText(ContextRef context, const char* text, uint64_t bytes) {
    sqlite3_result_text64(context, text, bytes, SQLITE_STATIC, SQLITE_UTF8);
}

TK_ALWAYS_INLINE void ContextResultNull(ContextRef context) {
    sqlite3_result_null(context);
}

typedef void (*FunctionExecute)(ContextRef context, int valuesCount, ValueRef _Nonnull * _Nonnull values);
typedef void (*FunctionStep)(ContextRef context, int valuesCount, ValueRef _Nonnull * _Nonnull values);
typedef void (*FunctionFinalize)(ContextRef context);
typedef void (*FunctionDestroy)(void *info);

/*!
 @struct TKDBFunctionContext
 
 @abstract This structure contains properties and callbacks that define an SQL function that will be added to the database.
 */
typedef struct {
    const char *name;
    int valuesCount;
    void *info;
    bool deterministic;
    FunctionExecute     execute;
    FunctionStep        step;
    FunctionFinalize    finalize;
    FunctionDestroy     destroy;
} FunctionContext;

TK_EXTERN const FunctionContext FunctionContextEmpty;

}

TK_ASSUME_NONNULL_END

#endif /* TK_FUNCTION_CONTEXT_H */
