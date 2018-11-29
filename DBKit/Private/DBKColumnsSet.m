/*
 *  DBKColumnsSet.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "DBKColumnsSet.h"
#import "DBKDefines.h"

@implementation DBKColumnsSet {
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

#pragma mark - DBKRow
#pragma mark By Name

- (DBKValueType)valueTypeForColumn:(NSString *)columnName {
    return (DBKValueType)sqlite3_column_type(_stmt, (int)[_columnMap indexOfObject:columnName]);
}

- (const void*)blobForColumn:(NSString *)columnName {
    return sqlite3_column_blob(_stmt, (int)[_columnMap indexOfObject:columnName]);
}

- (int)bytesForColumn:(NSString *)columnName {
    return sqlite3_column_bytes(_stmt, (int)[_columnMap indexOfObject:columnName]);
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

- (NSData *)dataForColumn:(NSString *)columnName {
    return [NSData dataWithBytes:[self blobForColumn:columnName] length:[self bytesForColumn:columnName]];
}

#pragma mark By Index

- (DBKValueType)valueTypeForColumnAtIndex:(DBKInt)columnIndex; {
    return (DBKValueType)sqlite3_column_type(_stmt, (int)columnIndex);
}

- (const void*)blobForColumnAtIndex:(DBKInt)columnIndex {
    return sqlite3_column_blob(_stmt, (int)columnIndex);
}

- (int)bytesForColumnAtIndex:(DBKInt)columnIndex {
    return sqlite3_column_bytes(_stmt, (int)columnIndex);
}

- (double)doubleForColumnAtIndex:(DBKInt)columnIndex {
    return sqlite3_column_double(_stmt, (int)columnIndex);
}

- (int64_t)int64ForColumnAtIndex:(DBKInt)columnIndex {
    return (int64_t)sqlite3_column_int64(_stmt, (int)columnIndex);
}

- (const char *)textForColumnAtIndex:(DBKInt)columnIndex {
    return (const char *)sqlite3_column_text(_stmt, (int)columnIndex);
}

- (NSString *)stringForColumnAtIndex:(DBKInt)columnIndex {
    return [NSString stringWithUTF8String:[self textForColumnAtIndex:columnIndex]];
}

- (NSData *)dataForColumnAtIndex:(DBKInt)columnIndex {
    return [NSData dataWithBytes:[self blobForColumnAtIndex:columnIndex] length:[self bytesForColumnAtIndex:columnIndex]];
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
