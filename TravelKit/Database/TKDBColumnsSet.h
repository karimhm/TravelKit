/*
 *  TKDBColumnsSet.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKDBRow.h>
#import <sqlite3.h>

@interface TKDBColumnsSet : NSObject <TKDBRow>

- (instancetype)initWithStmt:(sqlite3_stmt *)stmt columnMap:(NSArray <NSString *> *)columnMap;

@end
