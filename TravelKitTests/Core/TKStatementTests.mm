/*
 *  TKStatementTests.mm
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "TKDBTestCase.h"
#import "Database.h"
#import "Statement.h"

using namespace tk;

@interface TKStatementTests : TKDBTestCase

@property (nonatomic) Ref<Database> db;

@end

@implementation TKStatementTests : TKDBTestCase

- (void)setUp {
    [super setUp];
    
    self.db = makeRef<Database>(self.dbPath.UTF8String);
    XCTAssertTrue(self.db->open(Options::OpenReadOnly).isOK(), "Unable to open the test database");
}

- (void)tearDown {
    [super tearDown];
    
    XCTAssertTrue(self.db->close().isOK(), "Unable to close the test database");
}

- (void)testCreateStatement {
    Ref<Database> db = self.db;
    Ref<Statement> stmt = makeRef<Statement>(db, "SELECT value FROM test WHERE id = 1");
    
    XCTAssertTrue(stmt->prepare().isOK(), "Unable to prepare the statement");
    XCTAssertTrue(stmt->handle(), "'handle' is null");
    XCTAssertTrue(stmt->close().isOK(), "Unable to close the statament");
    XCTAssertTrue(stmt->isClosed(), "The statament should be marked as closed");
    
    stmt = makeRef<Statement>(db, "SELECT value FROM test WHERE id = %i", 1);
    XCTAssertTrue(stmt->prepare().isOK(), "Failed to prepare the statement");
    XCTAssertTrue(stmt->close().isOK(), "Unable to close the statament");
}

- (void)testBindParameters {
    Ref<Database> db = self.db;
    Ref<Statement> stmt = makeRef<Statement>(db, "SELECT value, id FROM test WHERE id = ?1;");
    
    int64_t value = 1;
    
    XCTAssertTrue(stmt->prepare().isOK(), "Failed to prepare the statement");
    XCTAssertTrue(stmt->bind(value, 1).isOK(), "Failed to bind the parameter number '1'");
    XCTAssertTrue(stmt->expandedQuery() == "SELECT value, id FROM test WHERE id = 1;", "The query is incorrect");
    XCTAssertTrue(stmt->next().isRow(), "Failed to call next");
    XCTAssertTrue((*stmt)["value"].stringValue() == "text", "The statement 'id' value is incorrent");
    XCTAssertTrue((*stmt)["id"].int64Value() == value, "The statement 'id' value is incorrent");
    XCTAssertTrue(stmt->close().isOK(), "Unable to close the statament");
}

- (void)testIsReadOnly {
    Ref<Database> db = self.db;
    Ref<Statement> stmt = makeRef<Statement>(db, "SELECT value FROM test");
    
    XCTAssertTrue(stmt->isReadOnly(), "The statement should me marked as readonly");
    XCTAssertTrue(stmt->close().isOK(), "Unable to close the statament");
}

- (void)testColumnMap {
    Ref<Database> db = self.db;
    Ref<Statement> stmt = makeRef<Statement>(db, "SELECT value, id FROM test");
    
    XCTAssertTrue(stmt->prepare().isOK(), "Failed to prepare the statement");
    XCTAssertTrue(stmt->next().isRow() , "Failed to call next");
    
    XCTAssertTrue(stmt->columnMap().size() == 2, "The columnMap should contain 2 columns");
    
    int32_t valueIndex = stmt->columnMap()["value"];
    XCTAssertTrue(strcmp(sqlite3_column_name(stmt->handle(), valueIndex), "value") == 0, "The column index is not correct");
    XCTAssertTrue(strcmp(sqlite3_column_name(stmt->handle(), valueIndex), "id") != 0, "The column index is not correct");
    
    XCTAssertTrue(stmt->close().isOK(), "Unable to close the statament");
}

- (void)testClearingBindings {
    Ref<Database> db = self.db;
    Ref<Statement> stmt = makeRef<Statement>(db, "SELECT value FROM test WHERE id = ?1");
    
    XCTAssertTrue(stmt->prepare().isOK(), "Failed to prepare the statement");
    
    XCTAssertTrue(stmt->bind(1, 1).isOK(), "Failed to bind the parameter number '1'");
    XCTAssertTrue(stmt->clearBindings().isOK(), "Failed to clear bindings");
    XCTAssertTrue(stmt->expandedQuery() == "SELECT value FROM test WHERE id = NULL", "The statement was not cleared");
    
    XCTAssertTrue(stmt->close().isOK(), "Unable to close the statament");
}

@end
