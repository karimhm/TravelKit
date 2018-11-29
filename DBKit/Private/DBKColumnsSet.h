/*
 *  TKDBColumnsSet.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <DBKit/DBKRow.h>
#import <sqlite3.h>

@interface DBKColumnsSet : NSObject <DBKRow>

- (instancetype)initWithStmt:(sqlite3_stmt *)stmt columnMap:(NSArray <NSString *> *)columnMap;

@end
