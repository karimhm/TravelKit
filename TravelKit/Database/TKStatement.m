/*
 *  TKStatement.m
 *  Created on 4/Mar/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStatement.h"
#import "TKDBColumnsSet.h"
#import "TKDatabase_Private.h"
#import "NSError+TravelKit.h"

@implementation TKStatement {
    TKDatabase *_db;
    NSString *_text;
    sqlite3_stmt *_stmt;
    NSInteger _columnCount;
    NSMutableArray <NSString *> *_columnMap;
    TKDBColumnsSet *_columnsSet;
    BOOL _hasNext;
}

- (instancetype)initWithDatabase:(TKDatabase *)database text:(NSString *)text {
    if (self = [super init]) {
        _db = database;
        _text = text;
        _columnMap = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDatabase:(TKDatabase *)database format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *text = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    return [self initWithDatabase:database text:text];
}

- (BOOL)prepareWithError:(NSError **)error {
    int status = sqlite3_prepare_v2(_db.sqlitePtr, _text.UTF8String, -1, &_stmt, nil);
    
    if (status == SQLITE_OK) {
        _columnCount = sqlite3_column_count(_stmt);
        _hasNext = (_columnCount > 0);
        
        for (int colIdx = 0; colIdx < _columnCount; colIdx++) {
            [_columnMap addObject:[NSString stringWithUTF8String:sqlite3_column_name(_stmt, colIdx)]];
        }
        
        _columnsSet = [[TKDBColumnsSet alloc] initWithStmt:_stmt columnMap:_columnMap];
    }
    
    return [self checkSQLStatus:status error:error];
}

- (sqlite3_stmt *)sqlitePtr {
    return _stmt;
}

- (BOOL)isBusy {
    return sqlite3_stmt_busy(_stmt);
}

- (NSInteger)columnCount {
    return _columnCount;
}

- (NSArray<NSString *> *)columnNames {
    return _columnMap;
}

- (BOOL)checkSQLStatus:(int)status error:(NSError **)error {
    if (status == SQLITE_OK) {
        if (error) {
            *error = nil;
        }
        return true;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWith:status];
        }
        return false;
    }
}

#pragma mark - Bind

- (BOOL)bindDouble:(double)value index:(NSInteger)index error:(NSError **)error {
    int status = sqlite3_bind_double(_stmt, (int)index, value);
    return [self checkSQLStatus:status error:error];
}

- (BOOL)bindInteger:(NSInteger)value index:(NSInteger)index error:(NSError **)error {
    int status = sqlite3_bind_int(_stmt, (int)index, (int)value);
    return [self checkSQLStatus:status error:error];
}

- (BOOL)bindString:(NSString *)value index:(NSInteger)index error:(NSError **)error {
    const char* text = value.UTF8String;
    size_t length = strlen(text);
    int status = sqlite3_bind_text64(_stmt, (int)index, text, (sqlite3_uint64)length, SQLITE_TRANSIENT, SQLITE_UTF8);
    return [self checkSQLStatus:status error:error];
}

- (BOOL)bindData:(NSData *)value index:(NSInteger)index error:(NSError **)error {
    int status = sqlite3_bind_blob64(_stmt, (int)index, value.bytes, (sqlite3_uint64)value.length, SQLITE_TRANSIENT);
    return [self checkSQLStatus:status error:error];
}

- (BOOL)bindNullWithIndex:(NSInteger)index error:(NSError **)error {
    int status = sqlite3_bind_null(_stmt, (int)index);
    return [self checkSQLStatus:status error:error];
}

- (NSString *)expandedQuery {
    if (@available(iOS 10.0, *)) {
        return [NSString stringWithUTF8String:sqlite3_expanded_sql(_stmt)];
    } else {
        return nil;
    }
}

#pragma mark - Execute

- (BOOL)executeWithError:(NSError **)error {
    int status = sqlite3_step(_stmt);
    
    if (status == SQLITE_DONE) {
        if (error) {
            *error = nil;
        }
        return true;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWith:status];
        } else {
            [_db reportError:[NSError tk_sqliteErrorWith:status]];
        }
        return false;
    }
}

- (id <TKDBRow>)next {
    if (_stmt && _hasNext) {
        int status = sqlite3_step(_stmt);
        
        if (status == SQLITE_ROW) {
            return _columnsSet;
        } else if (status == SQLITE_DONE) {
            _hasNext = false;
        } else if (status == SQLITE_BUSY || status == SQLITE_LOCKED) {
            [_db reportError:[NSError tk_databaseBusyError]];
            _hasNext = false;
        } else {
            [_db reportError:[NSError tk_sqliteErrorWith:status]];
            _hasNext = false;
        }
    }
    
    return nil;
}

- (BOOL)hasNext {
    return _hasNext;
}

- (BOOL)clearBindings {
    return [self clearBindingsWithError:nil];
}

- (BOOL)reset {
    return [self resetWithError:nil];
}

- (BOOL)close {
    return [self closeWithError:nil];
}

- (BOOL)clearBindingsWithError:(NSError **)error {
    int status = sqlite3_clear_bindings(_stmt);
    
    if (status == SQLITE_OK) {
        if (error) {
            *error = nil;
        }
        return true;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWith:status];
        } else {
            [_db reportError:[NSError tk_sqliteErrorWith:status]];
        }
        return false;
    }
}

- (BOOL)resetWithError:(NSError **)error {
    int status = sqlite3_reset(_stmt);
    
    if (status == SQLITE_OK) {
        _hasNext = true;
        if (error) {
            *error = nil;
        }
        return true;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWith:status];
        } else {
            [_db reportError:[NSError tk_sqliteErrorWith:status]];
        }
        return false;
    }
}

- (BOOL)closeWithError:(NSError **)error {
    if (_closed || !_stmt) {
        return true;
    }
    
    int status = sqlite3_finalize(_stmt);
    
    if (status == SQLITE_OK) {
        _closed = true;
        _stmt = NULL;
        if (error) {
            *error = nil;
        }
        return true;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWith:status];
        } else {
            [_db reportError:[NSError tk_sqliteErrorWith:status]];
        }
        return false;
    }
}

#pragma mark - NSEnumeration

- (nullable id)nextObject {
    return [self next];
}

#pragma mark -

- (void)dealloc {
    if (_stmt) {
        sqlite3_finalize(_stmt);
    }
    _columnMap = nil;
}

@end
