/*
 *  TKItem_Private.h
 *  Created on 14/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKItem.h"
#import "TKDBVerify.h"
#import "TKDBRow.h"
#import "TKConstants_Private.h"

@protocol TKItemManager <NSObject>

- (__kindof TKItem *)itemWithIdentifier:(int64_t)identifier table:(NSString *)table error:(NSError **)error;

@end

@interface TKItem () <TKDBVerify>

- (instancetype)initWithRow:(id <TKDBRow>)row manager:(id <TKItemManager>)manager;

- (NSString *)tableName;

@end
