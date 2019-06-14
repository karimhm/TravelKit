/*
 *  TKTime.h
 *  Created on 6/Jun/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface TKTime : NSObject <NSCopying, NSCoding, NSSecureCoding>

@property (nonatomic, readonly) NSInteger second;
@property (nonatomic, readonly) NSInteger minute;
@property (nonatomic, readonly) NSInteger hour;
@property (nonatomic, readonly) NSInteger day;

@end
