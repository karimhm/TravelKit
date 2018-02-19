/*
 *  TKDBRow_Private.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDBRow.h"
#import "TKDBCursor.h"
#import <sqlite3.h>

@interface TKDBRow ()

+ (instancetype)rowWithCursor:(TKDBCursor *)cursor;
- (instancetype)initWithCursor:(TKDBCursor *)cursor;

@end
