/*
 *  TKDBQuery.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDBQuery.h"

@implementation TKDBQuery

+ (instancetype)queryWithTable:(NSString *)tableName {
    TKDBQuery *query = [[TKDBQuery alloc] initWithSQLString:[NSString stringWithFormat:@"SELECT * FROM %@", tableName]];
    return query;
}

- (instancetype)initWithSQLString:(NSString *)sqlString {
    if (self = [super init]) {
        _sqlString = sqlString;
    }
    return self;
}

- (void)dealloc {
    _sqlString = nil;
}

@end
