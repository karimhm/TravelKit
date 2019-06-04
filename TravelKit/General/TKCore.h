/*
 *  TKCore.h
 *  Created on 31/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, TKTravelDirection) {
    TKTravelDirectionUnknown         = 0,
    TKTravelDirectionOutbound        = 1,
    TKTravelDirectionInbound         = 2
};

typedef uint64_t TKItemID;
typedef int64_t TKInt;
