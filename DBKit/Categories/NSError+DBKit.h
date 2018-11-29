/*
 *  NSError+DBKit.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface NSError (DBKit)

+ (instancetype)dbk_noSuchFileError;
+ (instancetype)dbk_invalidPathError;
+ (instancetype)dbk_noReadPermissionError;
+ (instancetype)dbk_noWritePermissionError;
+ (instancetype)dbk_badDatabaseError;
+ (instancetype)dbk_databaseBusyError;

+ (instancetype)dbk_sqliteErrorWith:(int)code db:(sqlite3*)db;

@end
