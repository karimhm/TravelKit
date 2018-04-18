/*
 *  TKItem.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface TKItem : NSObject

@property (nonatomic, readonly) int64_t identifier;
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
