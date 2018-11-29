/*
 *  NSError+DBKit.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "NSError+DBKit.h"
#import "DBKError.h"

@implementation NSError (DBKit)

#pragma mark - DBKit Error

+ (instancetype)dbk_noSuchFileError {
    return [NSError errorWithDomain:DBKErrorDomain code:DBKErrorNoSuchFile userInfo:nil];
}

+ (instancetype)dbk_invalidPathError {
    return [NSError errorWithDomain:DBKErrorDomain code:DBKErrorInvalidPath userInfo:nil];
}

+ (instancetype)dbk_noReadPermissionError {
    return [NSError errorWithDomain:DBKErrorDomain code:DBKErrorNoReadPermission userInfo:nil];
}

+ (instancetype)dbk_noWritePermissionError {
    return [NSError errorWithDomain:DBKErrorDomain code:DBKErrorNoWritePermission userInfo:nil];
}

+ (instancetype)dbk_badDatabaseError {
    return [NSError errorWithDomain:DBKErrorDomain code:DBKErrorBadDatabase userInfo:nil];
}

+ (instancetype)dbk_databaseBusyError {
    return [NSError errorWithDomain:DBKErrorDomain code:DBKErrorDatabaseBusy userInfo:nil];
}

#pragma mark - SQLite Error

+ (instancetype)dbk_sqliteErrorWith:(int)code db:(sqlite3*)db {
    return [NSError errorWithDomain:DBKSQLiteErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithUTF8String:sqlite3_errmsg(db)]}];
}

@end
