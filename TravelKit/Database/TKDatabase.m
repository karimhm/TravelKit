/*
 *  TKDatabase.m
 *  Created on 13/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDatabase.h"
#import "TKDatabase_Private.h"
#import "TKStatement.h"
#import "TKUtilities.h"
#import "TKDefines.h"
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
            _sqlitePtr = _db;
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
        _sqlitePtr = nil;
        _open = false;
    } else {
        [self reportError:[NSError tk_sqliteErrorWith:status]];
    }
    
    return closed;
}

- (BOOL)checkDatabase {
    TKStatement *statement = [[TKStatement alloc] initWithDatabase:self text:@"SELECT name FROM sqlite_master WHERE [type] = 'table'"];
    BOOL valid = false;
    
    if ([statement prepareWithError:nil]) {
        _valid = [statement next] != nil;
        [statement close];
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

#pragma mark - Checking

- (BOOL)tableExists:(NSString*)tableName {
    TKStatement *statement = [[TKStatement alloc] initWithDatabase:self format:@"SELECT name FROM sqlite_master WHERE [type] = 'table' AND name = '%@'", tableName];
    BOOL exists = false;
    
    if ([statement prepareWithError:nil]) {
        if (statement && ([statement next] != nil)) {
            exists = true;
            [statement close];
        }
    }
    
    return exists;
}

- (BOOL)columnExists:(NSString*)columnName inTableWithName:(NSString*)tableName {
    TKStatement *statement = [[TKStatement alloc] initWithDatabase:self format:@"PRAGMA table_info('%@')", tableName];
    BOOL exists = false;
    
    if ([statement prepareWithError:nil]) {
        for (id<TKDBRow> row in statement) {
            if ([[[row stringForColumn:@"name"] lowercaseString] isEqualToString:[columnName lowercaseString]]) {
                exists = true;
                [statement close];
                break;
            }
        }
    }
    
    return exists;
}

#pragma mark -

- (void)dealloc {
    _url = nil;
}

@end
