/*
 *  TKItem.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKDefines.h>
#import <TravelKit/TKCore.h>
#import <Foundation/Foundation.h>

NS_SWIFT_NAME(Item)
@interface TKItem : NSObject <NSCopying, NSCoding, NSSecureCoding>

@property (nonatomic, readonly) TKItemID identifier;
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end

TK_EXTERN NSString *TKItemIdentifier(TKItem *item);
TK_EXTERN TKItemID TKItemIDFromString(NSString *string);
