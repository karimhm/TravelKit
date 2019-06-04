/*
 *  TKDefines.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <sqlite3.h>
#import <unistd.h>
#import <machine/endian.h>

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

#define TK_ALWAYS_INLINE inline __attribute__((always_inline))

#define TK_RETURNS_NONNULL __attribute__((returns_nonnull))

#define TK_WARN_UNUSED_RETURN __attribute__((__warn_unused_result__))

#define TK_INLINE static inline

#define TK_INLINE_FUNCTION static inline

#define TK_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#define TK_ASSUME_NONNULL_END   _Pragma("clang assume_nonnull end")

#define TK_LIKE_PRINTF(f, a) __attribute__((format(__printf__, f, a)))

#define TK_STRINGIFY(x) #x
