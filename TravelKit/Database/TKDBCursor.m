/*
 *  TKDBCursor.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDBCursor.h"
#import "TKDBCursor_Private.h"
#import "TKDBColumnsSet.h"
#import "NSError+TravelKit.h"
#import <sqlite3.h>

@implementation TKDBCursor {
    TKDBColumnsSet *_columnsSet;
    sqlite3_stmt* _stmt;
    id<TKDBErrorReporter> _errorReporter;
    BOOL _hasNext;
}

- (instancetype)initWithStmt:(sqlite3_stmt *)stmt {
    if (self = [super init]) {
        _stmt = stmt;
        
        int columnCount = sqlite3_column_count(_stmt);
        NSMutableArray *columnNames = [[NSMutableArray alloc] initWithCapacity:columnCount];
        
        for (int colIdx = 0; colIdx < columnCount; colIdx++) {
            [columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(_stmt, colIdx)]];
        }
        
        _columnsSet = [[TKDBColumnsSet alloc] initWithStmt:_stmt columnMap:columnNames];
        _columnNames = columnNames;
        _hasNext = (columnCount > 0);
    }
   return self;
}

- (void)setErrorReporter:(id<TKDBErrorReporter>)reporter {
    _errorReporter = reporter;
}

- (NSInteger)count {
    return sqlite3_column_count(_stmt);
}

- (id <TKDBRow>)next {
    if (_stmt && _hasNext) {
        int status = sqlite3_step(_stmt);
        
        if (status == SQLITE_ROW) {
            return _columnsSet;
        } else if (status == SQLITE_DONE) {
            _hasNext = false;
        } else if (status == SQLITE_BUSY || status == SQLITE_LOCKED) {
            [_errorReporter reportError:[NSError tk_databaseBusyError]];
            _hasNext = false;
        } else {
            [_errorReporter reportError:[NSError tk_sqliteErrorWith:status]];
            _hasNext = false;
        }
    }
    
    return nil;
}

- (BOOL)hasNext {
    return _hasNext;
}

- (BOOL)reset {
    int status = sqlite3_reset(_stmt);
    if (status == SQLITE_DONE) {
        _hasNext = true;
        return true;
    } else {
        [_errorReporter reportError:[NSError tk_sqliteErrorWith:status]];
        return false;
    }
}

- (BOOL)close {
    if (_closed || !_stmt) {
        return true;
    }
    
    int status = sqlite3_finalize(_stmt);
    if (status == SQLITE_OK) {
        _closed = true;
        _stmt = NULL;
        return true;
    } else {
        [_errorReporter reportError:[NSError tk_sqliteErrorWith:status]];
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
    _columnsSet = nil;
}

@end
