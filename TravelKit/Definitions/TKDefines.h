/*
 *  TKDefines.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <stdio.h>
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

#define TK_ALWAYS_INLINE static inline __attribute__((always_inline))

#define TK_INLINE static inline

#define TK_STRINGIFY(x) #x

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

typedef int64_t TKItemID;
