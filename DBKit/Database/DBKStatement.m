/*
 *  DBKStatement.m
 *  Created on 4/Mar/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "DBKStatement.h"
#import "DBKColumnsSet.h"
#import "DBKDatabase_Private.h"
#import "NSError+DBKit.h"
#import <objc/runtime.h>

#define _DBK_C_LDBL 'D'

@implementation DBKStatement {
    DBKDatabase *_db;
    NSString *_text;
    sqlite3_stmt *_stmt;
    DBKInt _columnCount;
    NSMutableArray <NSString *> *_columnMap;
    DBKColumnsSet *_columnsSet;
    BOOL _hasNext;
    BOOL _didComplete;
    NSMutableDictionary *_parameters;
}

- (instancetype)initWithDatabase:(DBKDatabase *)database text:(NSString *)text {
    if (self = [super init]) {
        _db = database;
        _text = text;
        _columnMap = [[NSMutableArray alloc] init];
        _parameters = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithDatabase:(DBKDatabase *)database format:(NSString *)format, ... {
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
        _didComplete = false;
        
        for (int colIdx = 0; colIdx < _columnCount; colIdx++) {
            [_columnMap addObject:[NSString stringWithUTF8String:sqlite3_column_name(_stmt, colIdx)]];
        }
        
        _columnsSet = [[DBKColumnsSet alloc] initWithStmt:_stmt columnMap:_columnMap];
    }
    
    return [self checkSQLStatus:status error:error];
}

- (sqlite3_stmt *)sqlitePtr {
    return _stmt;
}

- (BOOL)isBusy {
    return sqlite3_stmt_busy(_stmt);
}

- (DBKInt)columnCount {
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
            *error = [NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr];
        }
        return false;
    }
}

#pragma mark - Bind

- (BOOL)bindDouble:(double)value index:(DBKInt)index error:(NSError **)error {
    int status = sqlite3_bind_double(_stmt, (int)index, value);
    return [self checkSQLStatus:status error:error];
}

- (BOOL)bindInteger:(DBKInt)value index:(DBKInt)index error:(NSError **)error {
    int status = sqlite3_bind_int64(_stmt, (int)index, (sqlite3_int64)value);
    return [self checkSQLStatus:status error:error];
}

- (BOOL)bindString:(NSString *)value index:(DBKInt)index error:(NSError **)error {
    const char* text = value.UTF8String;
    size_t length = strlen(text);
    int status = sqlite3_bind_text64(_stmt, (int)index, text, (sqlite3_uint64)length, SQLITE_TRANSIENT, SQLITE_UTF8);
    return [self checkSQLStatus:status error:error];
}

- (BOOL)bindData:(NSData *)value index:(DBKInt)index error:(NSError **)error {
    int status = sqlite3_bind_blob64(_stmt, (int)index, value.bytes, (sqlite3_uint64)value.length, SQLITE_TRANSIENT);
    return [self checkSQLStatus:status error:error];
}

- (BOOL)bindNullWithIndex:(DBKInt)index error:(NSError **)error {
    int status = sqlite3_bind_null(_stmt, (int)index);
    return [self checkSQLStatus:status error:error];
}

- (NSString *)expandedQuery {
    if (@available(iOS 10.0, *)) {
        const char* expanded = sqlite3_expanded_sql(_stmt);
        if (expanded) {
            return [NSString stringWithUTF8String:sqlite3_expanded_sql(_stmt)];
        }
    }
    
    return nil;
}

#pragma mark - Execute

- (BOOL)executeWithError:(NSError **)error {
    int status = sqlite3_step(_stmt);
    
    if (status == SQLITE_DONE) {
        if (error) {
            *error = nil;
        }
        _didComplete = true;
        return true;
    } else {
        if (error) {
            *error = [NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr];
        } else {
            [_db reportError:[NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr]];
        }
        return false;
    }
}

- (id <DBKRow>)next {
    if (_stmt && _hasNext) {
        int status = sqlite3_step(_stmt);
        
        if (status == SQLITE_ROW) {
            return _columnsSet;
        } else if (status == SQLITE_DONE) {
            _hasNext = false;
            _didComplete = true;
        } else if (status == SQLITE_BUSY || status == SQLITE_LOCKED) {
            [_db reportError:[NSError dbk_databaseBusyError]];
            _hasNext = false;
            _didComplete = false;
        } else {
            [_db reportError:[NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr]];
            _hasNext = false;
            _didComplete = false;
        }
    }
    
    return nil;
}

- (BOOL)hasNext {
    return _hasNext;
}

- (BOOL)didComplete {
    return _didComplete;
}

- (BOOL)clearAndReset {
    return [self clearAndResetWithError:nil];
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


- (BOOL)clearAndResetWithError:(NSError **)error {
    BOOL status = [self clearBindingsWithError:error];
    
    if (status) {
        status = [self resetWithError:error];
    }
    
    return status;
}

- (BOOL)clearBindingsWithError:(NSError **)error {
    int status = sqlite3_clear_bindings(_stmt);
    
    [_parameters removeAllObjects];
    
    if (status == SQLITE_OK) {
        if (error) {
            *error = nil;
        }
        return true;
    } else {
        if (error) {
            *error = [NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr];
        }
        [_db reportError:[NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr]];
        return false;
    }
}

- (BOOL)resetWithError:(NSError **)error {
    int status = sqlite3_reset(_stmt);
    
    if (status == SQLITE_OK) {
        _hasNext = true;
        _didComplete = false;
        if (error) {
            *error = nil;
        }
        return true;
    } else {
        if (error) {
            *error = [NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr];
        }
        [_db reportError:[NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr]];
        return false;
    }
}

- (BOOL)closeWithError:(NSError **)error {
    if (_closed || !_stmt) {
        return true;
    }
    
    [_parameters removeAllObjects];
    
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
            *error = [NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr];
        } else {
            [_db reportError:[NSError dbk_sqliteErrorWith:status db:_db.sqlitePtr]];
        }
        return false;
    }
}

#pragma mark - Key Value coding

- (nullable id)objectForKeyedSubscript:(nullable NSString *)key {
    return _parameters[key];
}

- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key {
    int index = sqlite3_bind_parameter_index(_stmt, key.UTF8String);
    if (index) {
        [self setObject:obj atIndexedSubscript:index];
        if (obj) {
            _parameters[key] = obj;
        }
    }
}
    
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index {
    if (!obj || [obj isKindOfClass:[NSNull class]]) {
        [self bindNullWithIndex:index error:nil];
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        char objCType = *[(NSNumber *)obj objCType];
        
        if (objCType == _C_FLT || objCType == _C_DBL || objCType == _DBK_C_LDBL) {
            [self bindDouble:[(NSNumber *)obj doubleValue] index:index error:nil];
        } else {
            [self bindInteger:[(NSNumber *)obj integerValue] index:index error:nil];
        }
    } else if ([obj isKindOfClass:[NSString class]]) {
        [self bindString:(NSString *)obj index:index error:nil];
    } else if ([obj isKindOfClass:[NSData class]]) {
        [self bindData:(NSData *)obj index:index error:nil];
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
