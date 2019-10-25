/*
 *  TKDefines_Private.h
 *  Created on 20/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKDefines.h"

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
    union stou {
        uint64_t uValue;
        int64_t sValue;
    } stou;
    stou.sValue = data;
    return stou.uValue;
}

TK_ALWAYS_INLINE int64_t TKUToS64(uint64_t data) {
    union utos {
        uint64_t uValue;
        int64_t sValue;
    } utos;
    utos.uValue = data;
    return utos.sValue;
}

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

#define TK_CONSTRUCTOR __attribute__((__constructor__))

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

TK_ALWAYS_INLINE BOOL TKSetError(NSError **pointer, NSError *error) {
    if (pointer) {
        *pointer = error;
    }
    
    return false;
}

#endif
