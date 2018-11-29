/*
 *  TKItem_Private.h
 *  Created on 14/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKItem.h"
#import "TKDBVerify.h"
#import "TKConstants_Private.h"
#import <DBKit/DBKRow.h>

@protocol TKItemManager <NSObject>

- (__kindof TKItem *)itemWithIdentifier:(TKItemID)identifier table:(NSString *)table error:(NSError **)error;

@end

@interface TKItem () <TKDBVerify>

- (instancetype)initWithRow:(id <DBKRow>)row manager:(id <TKItemManager>)manager;

- (NSString *)tableName;

@end
