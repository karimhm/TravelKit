/*
 *  TKItem.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKDefines.h>
#import <Foundation/Foundation.h>

@interface TKItem : NSObject

@property (nonatomic, readonly) TKItemID identifier;
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
