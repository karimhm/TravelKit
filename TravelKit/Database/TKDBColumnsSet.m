/*
 *  TKDBColumnsSet.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDBColumnsSet.h"

@implementation TKDBColumnsSet {
    sqlite3_stmt *_stmt;
    __weak NSArray <NSString *> *_columnMap;
    int _columnCount;
}

- (instancetype)initWithStmt:(sqlite3_stmt *)stmt columnMap:(NSArray <NSString *> *)columnMap {
    if (self = [super init]) {
        _stmt = stmt;
        _columnCount = sqlite3_column_count(stmt);
        _columnMap = columnMap;
    }
    return self;
}

#pragma mark - TKDBRow
#pragma mark By Name

- (TKDBValueType)valueTypeForColumn:(NSString *)columnName {
    return (TKDBValueType)sqlite3_column_type(_stmt, sqlite3_column_type(_stmt, (int)[_columnMap indexOfObject:columnName]));
}

- (const void*)blobForColumn:(NSString *)columnName {
    return sqlite3_column_blob(_stmt, (int)[_columnMap indexOfObject:columnName]);
}

- (double)doubleForColumn:(NSString *)columnName {
    return sqlite3_column_double(_stmt, (int)[_columnMap indexOfObject:columnName]);
}

- (int64_t)int64ForColumn:(NSString *)columnName {
    return (int64_t)sqlite3_column_int64(_stmt, (int)[_columnMap indexOfObject:columnName]);
}

- (const char *)textForColumn:(NSString *)columnName {
    return (const char *)sqlite3_column_text(_stmt, (int)[_columnMap indexOfObject:columnName]);
}

- (NSString *)stringForColumn:(NSString *)columnName {
    return [NSString stringWithUTF8String:[self textForColumn:columnName]];
}

#pragma mark By Index

- (TKDBValueType)valueTypeForColumnAtIndex:(NSInteger)columnIndex; {
    return (TKDBValueType)sqlite3_column_type(_stmt, sqlite3_column_type(_stmt, (int)columnIndex));
}

- (const void*)blobForColumnAtIndex:(NSInteger)columnIndex {
    return sqlite3_column_blob(_stmt, (int)columnIndex);
}
- (double)doubleForColumnAtIndex:(NSInteger)columnIndex {
    return sqlite3_column_double(_stmt, (int)columnIndex);
}

- (int64_t)int64ForColumnAtIndex:(NSInteger)columnIndex {
    return (int64_t)sqlite3_column_int64(_stmt, (int)columnIndex);
}

- (const char *)textForColumnAtIndex:(NSInteger)columnIndex {
    return (const char *)sqlite3_column_text(_stmt, (int)columnIndex);
}

- (NSString *)stringForColumnAtIndex:(NSInteger)columnIndex {
    return [NSString stringWithUTF8String:[self textForColumnAtIndex:columnIndex]];
}

#pragma mark - description

#ifdef DEBUG
- (NSString*)description {
    NSMutableString *ds = [[NSMutableString alloc] initWithFormat:@"<%@: %p; ", [self class], self];
    for (int colIdx = 0; colIdx < _columnCount; colIdx++) {
        [ds appendFormat:@"%s = %s%s ", sqlite3_column_name(_stmt, colIdx), sqlite3_column_text(_stmt, colIdx), (colIdx +1 == _columnCount) ? ">":";"];
    }
    return ds;
}
#endif

@end
