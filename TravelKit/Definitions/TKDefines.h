/*
 *  TKDefines.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <sqlite3.h>
#import <stdio.h>
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

TK_ALWAYS_INLINE uint64_t TKSToU64(int64_t data) {
    union utos {
        uint64_t uValue;
        int64_t sValue;
    } utos;
    utos.sValue = data;
    return utos.uValue;
}

TK_ALWAYS_INLINE int64_t TKUToS64(uint64_t data) {
    union utos {
        uint64_t uValue;
        int64_t sValue;
    } utos;
    utos.uValue = data;
    return utos.sValue;
}

typedef uint64_t TKItemID;
typedef int64_t TKInt;

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

#define TK_ENCODE_OBJ(c,x)  [c encodeObject:_ ## x forKey:@TK_STRINGIFY(x)]
#define TK_DECODE_OBJ_CLASS(d,x,cl)  _ ## x = (cl *)[d decodeObjectOfClass:[cl class] forKey:@TK_STRINGIFY(x)]
#define TK_DECODE_OBJ_ARRAY(d,x,cl)  _ ## x = (NSArray *)[d decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class],[cl class],nil] forKey:@TK_STRINGIFY(x)]

#define TK_ENCODE_BOOL(c,x)  [c encodeBool:_ ## x forKey:@TK_STRINGIFY(x)]
#define TK_DECODE_BOOL(d,x)  _ ## x = [d decodeBoolForKey:@TK_STRINGIFY(x)]

#define TK_ENCODE_INTEGER(c,x)  [c encodeInteger:_ ## x forKey:@TK_STRINGIFY(x)]
#define TK_DECODE_INTEGER(d,x)  _ ## x = [d decodeIntegerForKey:@TK_STRINGIFY(x)]

#define TK_ENCODE_DOUBLE(c,x)  [c encodeDouble:_ ## x forKey:@TK_STRINGIFY(x)]
#define TK_DECODE_DOUBLE(d,x)  _ ## x = [d decodeDoubleForKey:@TK_STRINGIFY(x)]

#define TK_ENCODE_INT32(c,x)  [c encodeInt32:_ ## x forKey:@TK_STRINGIFY(x)]
#define TK_DECODE_INT32(d,x) _ ## x = [d decodeInt32ForKey:@TK_STRINGIFY(x)]

#define TK_ENCODE_INT64(c,x)  [c encodeInt64:_ ## x forKey:@TK_STRINGIFY(x)]
#define TK_DECODE_INT64(d,x) _ ## x = [d decodeInt64ForKey:@TK_STRINGIFY(x)]

TK_INLINE_FUNCTION UIColor* TKColorFromHexRGB(UInt32 hex) {
    return [UIColor colorWithRed:((CGFloat)((hex & 0xff0000) >> 16)) / 255
                           green:((CGFloat)((hex & 0x00ff00) >>  8)) / 255
                            blue:((CGFloat)((hex & 0x0000ff) >>  0)) / 255
                           alpha:1];
}

#endif
