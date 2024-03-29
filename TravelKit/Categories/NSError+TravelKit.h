/*
 *  NSError+TravelKit.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface NSError (TravelKit)

+ (instancetype)tk_badDatabaseError;
+ (instancetype)tk_internalDatabaseError;

+ (instancetype)tk_sqliteErrorWithDB:(sqlite3*)db;
+ (instancetype)tk_sqliteErrorWithCode:(int)code message:(NSString *)message;

@end
