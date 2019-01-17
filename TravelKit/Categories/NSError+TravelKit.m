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

+ (instancetype)tk_badDatabaseError {
    return [NSError errorWithDomain:TKErrorDomain code:TKErrorBadDatabase userInfo:nil];
}

+ (instancetype)tk_internalDatabaseError {
    return [NSError errorWithDomain:TKErrorDomain code:TKErrorInternalDatabaseError userInfo:nil];
}

+ (instancetype)tk_sqliteErrorWithDB:(sqlite3*)db {
    return [NSError errorWithDomain:TKSQLiteErrorDomain code:sqlite3_errcode(db) userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithUTF8String:sqlite3_errmsg(db)]}];
}

@end
