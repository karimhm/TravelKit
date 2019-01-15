/*
 *  DBKDatabase.m
 *  Created on 13/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "DBKDatabase.h"
#import "DBKDatabase_Private.h"
#import "DBKStatement.h"
#import "DBKDefines.h"
#import "NSError+DBKit.h"
#import <sqlite3.h>

static DBKInt DBKDefaultBusyTimeout = 250;

int DBKOptionsToSQLiteFlags(DBKOptions options) {
    int flags = 0;
    
    if (options & DBKOptionsOpenReadWrite) {
        flags |= SQLITE_OPEN_READWRITE;
    } else if (options & DBKOptionsOpenReadOnly) {
        flags |= SQLITE_OPEN_READONLY;
    }
    
    if (options & DBKOptionsCreate) {
        flags |= SQLITE_OPEN_CREATE;
    }
    
    return flags;
}

int DBKDatabaseBusyHandler(void *ptr, int count) {
    DBKDatabase *db = (__bridge DBKDatabase*)ptr;
    
    if (db.delegate && [db.delegate databaseShouldHandleBusy:db]) {
        sqlite3_sleep((int)db.busyTimeout);
        return 1;
    }
    
    return 0;
}

BOOL DBKFileExists(NSString *path) {
    return (access(path.fileSystemRepresentation, F_OK ) != -1);
}

BOOL DBKFileReadable(NSString *path) {
    return (access(path.fileSystemRepresentation, R_OK ) != -1);
}

BOOL DBKFileWritable(NSString *path) {
    return (access(path.fileSystemRepresentation, W_OK ) != -1);
}

@implementation DBKDatabase {
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
    return [self openWithOptions:DBKOptionsOpenReadOnly error:nil];
}

- (BOOL)openReadWrite {
    return [self openWithOptions:DBKOptionsOpenReadWrite error:nil];
}

- (BOOL)openWithOptions:(DBKOptions)options error:(NSError **)error {
    if (_open) {
        return true;
    } else if (_db) {
        [self close];
    }
    
    BOOL valid = true;
    
    if (![_url isFileURL]) {
        valid = false;
        NSError *openError = [NSError dbk_invalidPathError];
        if (error) {
            *error = openError;
        }
        [self reportError:openError];
    }
    
    /*if (valid && !(options & DBKOptionsCreate)) {
        if (DBKFileExists(_url.path)) {
            valid = false;
            NSError *openError = [NSError dbk_invalidPathError];
            if (error) {
                *error = openError;
            }
            [self reportError:openError];
        }
    } else {
        if (!DBKFileReadable(_url.path)) {
            valid = false;
            NSError *openError = [NSError dbk_noReadPermissionError];
            if (error) {
                *error = openError;
            }
            [self reportError:openError];
        }
    }

    if (valid && (options & DBKOptionsOpenReadWrite)) {
        if (!DBKFileWritable(_url.path)) {
            valid = false;
            NSError *openError = [NSError dbk_noWritePermissionError];
            if (error) {
                *error = openError;
            }
            [self reportError:openError];
        }
    }*/
    
    if (valid) {
        int status = sqlite3_open_v2(_url.fileSystemRepresentation,
                                     &_db,
                                     DBKOptionsToSQLiteFlags(options),
                                     NULL);
        if (status == SQLITE_OK) {
            _open = true;
            _sqlitePtr = _db;
            valid = [self checkDatabase];
            self.busyTimeout = DBKDefaultBusyTimeout;
        } else {
            valid = false;
            NSError *openError = [NSError dbk_sqliteErrorWith:status db:_db];
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
        [self reportError:[NSError dbk_sqliteErrorWith:status db:_db]];
    }
    
    return closed;
}

- (BOOL)checkDatabase {
    DBKStatement *statement = [[DBKStatement alloc] initWithDatabase:self text:@"SELECT name FROM sqlite_master WHERE [type] = 'table'"];
    BOOL valid = false;
    
    if ([statement prepareWithError:nil]) {
        valid = [statement hasNext];
        [statement close];
    }
    
    return valid;
}

- (void)setBusyTimeout:(DBKInt)busyTimeout {
    _busyTimeout = busyTimeout;
    
    if (busyTimeout == 0) {
        sqlite3_busy_handler(_db, nil, nil);
        _busyHandlerSet = false;
    } else if(!_busyHandlerSet) {
        int status = sqlite3_busy_handler(_db, &DBKDatabaseBusyHandler, (__bridge void *)(self));
        if (status == SQLITE_OK) {
            _busyHandlerSet = true;
        } else {
            [self reportError:[NSError dbk_sqliteErrorWith:status db:_db]];
        }
    }
}

- (BOOL)addFunction:(DBKFunctionContext)function error:(NSError **)error {
    int status = sqlite3_create_function_v2(_db,
                                            function.name,
                                            function.valuesCount,
                                            function.deterministic ? (SQLITE_UTF8 | SQLITE_DETERMINISTIC) : (SQLITE_UTF8),
                                            function.info,
                                            function.execute,
                                            function.step,
                                            function.finalize,
                                            function.destroy);
    if (status == SQLITE_OK) {
        if (error) {
            *error = nil;
        }
        return true;
    } else {
        if (error) {
            *error = [NSError dbk_sqliteErrorWith:status db:_db];
        }
        return false;
    }
}

#pragma mark - DBKErrorReporter

- (void)reportError:(NSError *)error {
    if (_delegate) {
        [_delegate database:self didFailWithError:error];
    }
}

#pragma mark - Checking

- (BOOL)tableExists:(NSString*)tableName {
    DBKStatement *statement = [[DBKStatement alloc] initWithDatabase:self format:@"SELECT name FROM sqlite_master WHERE [type] = 'table' AND name = '%@'", tableName];
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
    DBKStatement *statement = [[DBKStatement alloc] initWithDatabase:self format:@"PRAGMA table_info('%@')", tableName];
    BOOL exists = false;
    
    if ([statement prepareWithError:nil]) {
        for (id<DBKRow> row in statement) {
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
