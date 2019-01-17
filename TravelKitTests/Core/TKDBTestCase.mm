/*
 *  TKDBTestCase.mm
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDBTestCase.h"

@implementation TKDBTestCase : XCTestCase

- (void)setUp {
    [super setUp];
    
    NSString *dbName = [NSString stringWithFormat:@"%@.db", [NSUUID UUID].UUIDString];
    self.dbPath = [NSTemporaryDirectory() stringByAppendingPathComponent:dbName];
    
    sqlite3* sqliteDB = nullptr;
    const char *filename = self.dbPath.UTF8String;
    int flags = SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE;
    int status = SQLITE_OK;
    
    status = sqlite3_open_v2(filename, &sqliteDB, flags, nullptr);
    XCTAssertTrue(status == SQLITE_OK, "Unable to open the test database");
    self.sqliteDB = sqliteDB;
    
    status = sqlite3_exec(self.sqliteDB, "CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT);", nullptr, nullptr, nullptr);
    XCTAssertTrue(status == SQLITE_OK, "Unable to create test table");
    
    status = sqlite3_exec(self.sqliteDB, "INSERT INTO test(id , value) VALUES(1, 'text');", nullptr, nullptr, nullptr);
    XCTAssertTrue(status == SQLITE_OK, "Unable to insert a test column");
}

- (void)tearDown {
    [super tearDown];
    
    int status = sqlite3_close(self.sqliteDB);
    XCTAssertTrue(status == SQLITE_OK, "Unable to close the test database");
    
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:self.dbPath error:nil];
    XCTAssertTrue(result, "Unable to delete the test database");
}

@end
