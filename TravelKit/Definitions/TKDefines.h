/*
 *  TKDefines.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#if defined(__cplusplus)
#define TK_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define TK_EXTERN extern __attribute__((visibility("default")))
#endif

#if defined(__BIG_ENDIAN__)
#define TK_BIG_ENDIAN
#elif defined(__BIG_ENDIAN__)
#define TK_LITTLE_ENDIAN
#else
#define TK_UNKNOWN_ENDIAN
#endif

#define TK_INLINE static inline

TK_INLINE uint32_t TKAligned32(uint32_t data) {
#if defined(TK_BIG_ENDIAN)
    return data;
#else
    return _OSSwapInt32(data);
#endif
}

typedef NS_ENUM(NSInteger, TKDBValueType) {
    TKDBValueTypeUnknown = -1,
    TKDBValueTypeNull = SQLITE_NULL,
    TKDBValueTypeInteger = SQLITE_INTEGER,
    TKDBValueTypeFloat = SQLITE_FLOAT,
    TKDBValueTypeText = SQLITE_TEXT,
    TKDBValueTypeBlob = SQLITE_BLOB
};
