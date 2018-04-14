/*
 *  NSError+TravelKit.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface NSError (TravelKit)

+ (instancetype)tk_noSuchFileError;
+ (instancetype)tk_invalidPathError;
+ (instancetype)tk_noReadPermissionError;
+ (instancetype)tk_noWritePermissionError;
+ (instancetype)tk_badDatabaseError;
+ (instancetype)tk_databaseBusyError;

+ (instancetype)tk_sqliteErrorWith:(int)code db:(sqlite3*)db;

@end
