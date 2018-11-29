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

@end
