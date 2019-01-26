/*
 *  TKItem_Private.h
 *  Created on 14/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKItem.h"
#import "TKDBVerify.h"
#import "TKConstants_Private.h"

@interface TKItem () <TKDBVerify>

- (NSString *)tableName;

@end
