/*
 *  TKCoreDatabaseTests.mm
 *  Created on 15/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "TKDBTestCase.h"
#import <sqlite3.h>
#import "Database.h"

using namespace tk;

@interface TKCoreDatabaseTests : TKDBTestCase

@end

void TKDatabaseTestCustomFunction(ContextRef context, int valuesCount, ValueRef _Nonnull * _Nonnull values) {
    ContextResultInt64(context, 1);
}

@implementation TKCoreDatabaseTests : TKDBTestCase

- (void)testOpenDatabase {
    Ref<Database> db = makeRef<Database>(self.dbPath.UTF8String);
    
    // Check if the databse open successfully
    XCTAssertTrue(db->open(Options::OpenReadOnly).isOK(), "The database was not opened successfully");
    
    // Check if the database handle read write flags correctly
    XCTAssertFalse(db->execute("INSERT INTO test(id , value) VALUES(2, 'text');").isOK(), "The Database is readonly. The statement should not execute successfully");
    XCTAssertTrue(db->open(Options::OpenReadWrite).isOK(), "The database was not opened successfully");
    XCTAssertTrue(db->execute("INSERT INTO test(id , value) VALUES(2, 'text');").isOK(), "The Database is readonly. The statement should not execute successfully");
    
    // The database should be marked as open if its open
    XCTAssertTrue(db->isOpen(), "'isOpen' is set to false");
    // The sqlite handle should not be null if the database is open
    XCTAssertTrue(db->handle() != nullptr, "'handle' is null");
    // Check if the database get closed successfully
    XCTAssertTrue(db->close().isOK(), "The database was not closed successfully");
    // The database should be marked as not open after closing it
    XCTAssertFalse(db->isOpen(), "'isOpen' is set to true");
    // Check if handle become null after closing the databse
    XCTAssertTrue(db->handle() == nullptr, "'handle' should be null");
}

- (void)testCheckTableAndColumnExist {
    Ref<Database> db = makeRef<Database>(self.dbPath.UTF8String);
    db->open(Options::OpenReadOnly);
    
    // Check if the table exist
    XCTAssertTrue(db->tableExist("test"), "'test' table doesn't exist");
    XCTAssertFalse(db->tableExist("notExisting"), "'not_existing' table does exist. It should not");
    
    // Check if the columns exist
    XCTAssertTrue(db->columnExist("test", "id"), "'value' column doesn't exist");
    XCTAssertFalse(db->columnExist("test", "notExisting"), "'not_existing' column does exist. It should not");
}

- (void)testCustomFunction {
    Ref<Database> db = makeRef<Database>(self.dbPath.UTF8String);
    db->open(Options::OpenReadOnly);
    
    FunctionContext function = FunctionContext::Empty();
    function.name = "customFunction";
    function.execute = TKDatabaseTestCustomFunction;
    
    // Check if the function was added
    XCTAssertTrue(db->addFunction(function).isOK(), "The function was not added successfully");
    XCTAssertTrue(db->execute("SELECT customFunction() as value;").isOK(), "The function should succeed");
    XCTAssertFalse(db->execute("SELECT notExistingFunction() as value;").isOK(), "The function should not succeed");
}

- (void)testValue {
    Value value = nullptr;
    
    // Check the value type and if it handle null values
    XCTAssertTrue(value.type() == ValueType::Unknown, "The value type should be unknown");
    XCTAssertFalse(value.isValid(), "The value should be marked as invalid");
}

@end
