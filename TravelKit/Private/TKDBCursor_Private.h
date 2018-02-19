/*
 *  TKDBCursor_Private.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDBCursor.h"
#import "TKDBErrorReporter.h"
#import <sqlite3.h>

@interface TKDBCursor ()

- (instancetype)initWithStmt:(sqlite3_stmt *)stmt;
- (void)setErrorReporter:(id<TKDBErrorReporter>)reporter;

@end
