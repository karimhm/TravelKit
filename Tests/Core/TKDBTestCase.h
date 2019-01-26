/*
 *  TKDBTestCase.h
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <XCTest/XCTest.h>
#import <sqlite3.h>

@interface TKDBTestCase : XCTestCase

@property (strong, nonatomic) NSString *dbPath;
@property (nonatomic) sqlite3 *sqliteDB;

@end
