/*
 *  TKDatabase.m
 *  Created on 13/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDatabase.h"
#import "TKUtilities.h"
#import "TKDefines.h"
#import "TKDBCursor_Private.h"
#import "NSError+TravelKit.h"
#import <sqlite3.h>

static NSInteger TKDefaultBusyTimeout = 250;

int TKDBOptionsToSQLiteFlags(TKDBOptions options) {
    int flags = 0;
    
    if (options & TKDBOptionsOpenReadWrite) {
        flags |= SQLITE_OPEN_READONLY;
    } else if (options & TKDBOptionsOpenReadOnly) {
        flags |= SQLITE_OPEN_READWRITE;
    }
    
    if (options & TKDBOptionsCreate) {
        flags |= SQLITE_OPEN_CREATE;
    }
    
    return flags;
}

int TKDatabaseBusyHandler(void *ptr, int count) {
    TKDatabase *db = (__bridge TKDatabase*)ptr;
    
    if (db.delegate && [db.delegate databaseShouldHandleBusy:db]) {
        sqlite3_sleep((int)db.busyTimeout);
        return 1;
    }
    
    return 0;
}

@interface TKDatabase () <TKDBErrorReporter>

@end

@implementation TKDatabase {
    sqlite3 *_db;
    NSURL *_url;
    BOOL _open;
    BOOL _busyHandlerSet;
    
}

#pragma mark - Initialization

- (instancetype)initWithPath:(NSString *)path {
    return [self initWithURL:[NSURL fileURLWithPath:path]];
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

- (BOOL)open {
    return [self openWithOptions:TKDBOptionsOpenReadOnly error:nil];
}

- (BOOL)openReadWrite {
    return [self openWithOptions:TKDBOptionsOpenReadWrite error:nil];
}

- (BOOL)openWithOptions:(TKDBOptions)options error:(NSError **)error {
    if (_open) {
        return true;
    } else if (_db) {
        [self close];
    }
    
    BOOL valid = true;
    
    if (![_url isFileURL]) {
        valid = false;
        NSError *openError = [NSError tk_invalidPathError];
        if (error) {
            *error = openError;
        }
        [self reportError:openError];
    }
    
    if (valid && !(options & TKDBOptionsCreate)) {
        if (!TKFileExists(_url.path)) {
            valid = false;
            NSError *openError = [NSError tk_noSuchFileError];
            if (error) {
                *error = openError;
            }
            [self reportError:openError];
        }
    } else {
        if (!TKFileReadable(_url.path)) {
            valid = false;
            NSError *openError = [NSError tk_noReadPermissionError];
            if (error) {
                *error = openError;
            }
            [self reportError:openError];
        }
    }

    if (valid && (options & TKDBOptionsOpenReadWrite)) {
        if (!TKFileWritable(_url.path)) {
            valid = false;
            NSError *openError = [NSError tk_noWritePermissionError];
            if (error) {
                *error = openError;
            }
            [self reportError:openError];
        }
    }
    
    if (valid) {
        int status = sqlite3_open_v2(_url.fileSystemRepresentation,
                                     &_db,
                                     TKDBOptionsToSQLiteFlags(options),
                                     NULL);
        if (status == SQLITE_OK) {
            _open = true;
            _valid = [self checkDatabase];
            self.busyTimeout = TKDefaultBusyTimeout;
        } else {
            valid = false;
            NSError *openError = [NSError tk_sqliteErrorWith:status];
            if (error) {
                *error = openError;
            }
            [self reportError:openError];
        }
    }
    
    _valid = valid;
    return valid;
}

- (BOOL)close {
    if (!_db) {
        return true;
    }
    
    sqlite3_busy_handler(_db, nil, nil);
    
    BOOL closed = false;
    int status = sqlite3_close(_db);
    
    if (status == SQLITE_OK) {
        closed = true;
        _db = nil;
        _open = false;
    } else {
        [self reportError:[NSError tk_sqliteErrorWith:status]];
    }
    
    return closed;
}

- (BOOL)checkDatabase {
    TKDBCursor *cursor = [self executeQueryWithFormat:@"SELECT name FROM sqlite_master WHERE [type] = 'table'"];
    BOOL valid = false;
    
    if (cursor) {
        valid = ([cursor next] != nil);
        [cursor close];
    }
    
    return valid;
}

- (void)setBusyTimeout:(NSInteger)busyTimeout {
    _busyTimeout = busyTimeout;
    
    if (busyTimeout == 0) {
        sqlite3_busy_handler(_db, nil, nil);
        _busyHandlerSet = false;
    } else if(!_busyHandlerSet) {
        int status = sqlite3_busy_handler(_db, &TKDatabaseBusyHandler, (__bridge void *)(self));
        if (status == SQLITE_OK) {
            _busyHandlerSet = true;
        } else {
            [self reportError:[NSError tk_sqliteErrorWith:status]];
        }
    }
}

#pragma mark - TKDBErrorReporter

- (void)reportError:(NSError *)error {
    if (_delegate) {
        [_delegate database:self didFailWithError:error];
    }
}

#pragma mark - Query

- (TKDBCursor *)executeQuery:(TKDBQuery *)query {
    return [self executeQuery:query error:nil];
}

- (TKDBCursor *)executeQuery:(TKDBQuery *)query error:(NSError **)error {
    return [self executeQueryWithString:query.sqlString error:error];
}

- (TKDBCursor *)executeQueryWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *queryString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    return [self executeQueryWithString:queryString error:nil];
}

- (TKDBCursor *)executeQueryWithString:(NSString *)string error:(NSError **)error {
    sqlite3_stmt *stmt;
    int status = sqlite3_prepare_v2(_db, string.UTF8String, -1, &stmt, NULL);
    
    if (status == SQLITE_OK) {
        TKDBCursor *cursor = [[TKDBCursor alloc] initWithStmt:stmt];
        return cursor;
    } else {
        sqlite3_finalize(stmt);
        NSError *executeError = [NSError tk_sqliteErrorWith:status];
        if (error) {
            *error = executeError;
        }
        [self reportError:executeError];
    }
    
    return nil;
}

#pragma mark - Checking

- (BOOL)tableExists:(NSString*)tableName {
    TKDBCursor *cursor = [self executeQueryWithFormat:@"SELECT name FROM sqlite_master WHERE [type] = 'table' AND name = '%@'", tableName];
    BOOL exists = false;
    
    if (cursor && ([cursor next] != nil)) {
        exists = true;
        [cursor close];
    }
    
    return exists;
}

- (BOOL)columnExists:(NSString*)columnName inTableWithName:(NSString*)tableName {
    TKDBCursor *cursor = [self executeQueryWithFormat:@"PRAGMA table_info('%@')", tableName];
    BOOL exists = false;
    
    for (id<TKDBRow> row in cursor) {
        if ([[[row stringForColumn:@"name"] lowercaseString] isEqualToString:[columnName lowercaseString]]) {
            exists = true;
            [cursor close];
            break;
        }
    }
    
    return exists;
}

#pragma mark -

- (void)dealloc {
    _url = nil;
}

@end
