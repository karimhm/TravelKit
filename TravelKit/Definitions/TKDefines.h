/*
 *  TKDefines.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <stdio.h>
#include <machine/endian.h>

#if defined(__cplusplus)
#define TK_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define TK_EXTERN extern __attribute__((visibility("default")))
#endif

#define TK_PACKED __attribute__((__packed__))

#if BYTE_ORDER == BIG_ENDIAN
#define TK_BIG_ENDIAN
#elif BYTE_ORDER == LITTLE_ENDIAN
#define TK_LITTLE_ENDIAN
#else
#error "Unable to determine the machine endianness"
#endif

#define TK_ALWAYS_INLINE static inline __attribute__((always_inline))

#define TK_INLINE static inline

TK_ALWAYS_INLINE uint32_t TKAligned32(uint32_t data) {
#if defined(TK_BIG_ENDIAN)
    return data;
#elif defined(TK_LITTLE_ENDIAN)
    return _OSSwapInt32(data);
#endif
}

TK_ALWAYS_INLINE uint64_t TKAligned64(uint64_t data) {
#if defined(TK_BIG_ENDIAN)
    return data;
#elif defined(TK_LITTLE_ENDIAN)
    return _OSSwapInt64(data);
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
