/*
 *  TKStop.h
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKStation.h>
#import <Foundation/Foundation.h>

typedef struct {
    uint32_t hour;
    uint32_t minute;
} TKTimeInfo;

@interface TKStop : NSObject

+ (instancetype)stopWithStation:(TKStation *)station time:(TKTimeInfo)time;

@property (nonatomic, readonly) TKStation *station;
@property (nonatomic, readonly) NSString *localizedTime;
@property (nonatomic, readonly) TKTimeInfo time;

@end
