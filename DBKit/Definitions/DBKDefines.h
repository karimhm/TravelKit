/*
 *  DBKDefines.h
 *  Created on 25/Nov/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <stdio.h>

#if defined(__cplusplus)
#define DBK_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define DBK_EXTERN extern __attribute__((visibility("default")))
#endif

#define DBK_ALWAYS_INLINE static inline __attribute__((always_inline))

typedef NS_ENUM(NSInteger, DBKValueType) {
    DBKValueTypeUnknown = -1,
    DBKValueTypeNull = SQLITE_NULL,
    DBKValueTypeInteger = SQLITE_INTEGER,
    DBKValueTypeFloat = SQLITE_FLOAT,
    DBKValueTypeText = SQLITE_TEXT,
    DBKValueTypeBlob = SQLITE_BLOB
};

typedef int64_t DBKInt;
