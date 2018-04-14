/*
 *  NSError+TravelKit.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "NSError+TravelKit.h"
#import "TKError.h"

@implementation NSError (TravelKit)

#pragma mark - TravelKit Error

+ (instancetype)tk_noSuchFileError {
    return [NSError errorWithDomain:TKErrorDomain code:TKErrorNoSuchFile userInfo:nil];
}

+ (instancetype)tk_invalidPathError {
    return [NSError errorWithDomain:TKErrorDomain code:TKErrorInvalidPath userInfo:nil];
}

+ (instancetype)tk_noReadPermissionError {
    return [NSError errorWithDomain:TKErrorDomain code:TKErrorNoReadPermission userInfo:nil];
}

+ (instancetype)tk_noWritePermissionError {
    return [NSError errorWithDomain:TKErrorDomain code:TKErrorNoWritePermission userInfo:nil];
}

+ (instancetype)tk_badDatabaseError {
    return [NSError errorWithDomain:TKErrorDomain code:TKErrorBadDatabase userInfo:nil];
}

+ (instancetype)tk_databaseBusyError {
    return [NSError errorWithDomain:TKErrorDomain code:TKErrorDatabaseBusy userInfo:nil];
}

#pragma mark - SQLite Error

+ (instancetype)tk_sqliteErrorWith:(int)code db:(sqlite3*)db {
    return [NSError errorWithDomain:TKSQLiteErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithUTF8String:sqlite3_errmsg(db)]}];
}

@end
