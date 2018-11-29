/*
 *  DBKStatement.h
 *  Created on 4/Mar/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <DBKit/DBKDatabase.h>
#import <DBKit/DBKRow.h>
#import <sqlite3.h>

@interface DBKStatement : NSEnumerator

- (instancetype)initWithDatabase:(DBKDatabase *)database text:(NSString *)text;
- (instancetype)initWithDatabase:(DBKDatabase *)database format:(NSString *)format, ...;

- (BOOL)bindDouble:(double)value index:(DBKInt)index error:(NSError **)error;
- (BOOL)bindInteger:(DBKInt)value index:(DBKInt)index error:(NSError **)error;
- (BOOL)bindString:(NSString *)value index:(DBKInt)index error:(NSError **)error;
- (BOOL)bindData:(NSData *)value index:(DBKInt)index error:(NSError **)error;
- (BOOL)bindNullWithIndex:(DBKInt)index error:(NSError **)error;

/*
 *  expandedQuery
 *
 *  Discussion:
 *    May return a NULL string.
 */
- (NSString *)expandedQuery;

@property (nonatomic, readonly) DBKInt columnCount;
@property (nonatomic, readonly) NSArray <NSString *> *columnNames;

@property (nonatomic, readonly, getter=isReadOnly) BOOL readOnly;
@property (nonatomic, readonly, getter=isbusy) BOOL busy;
@property (nonatomic, readonly, getter=isClosed) BOOL closed; 

@property (nonatomic, readonly) sqlite3_stmt* sqlitePtr;

- (BOOL)prepareWithError:(NSError **)error;
- (BOOL)executeWithError:(NSError **)error;

- (id<DBKRow>)next;
- (BOOL)hasNext;
- (BOOL)didComplete;

- (BOOL)clearAndReset;
- (BOOL)clearBindings;
- (BOOL)reset;
- (BOOL)close;

- (BOOL)clearAndResetWithError:(NSError **)error;
- (BOOL)clearBindingsWithError:(NSError **)error;
- (BOOL)resetWithError:(NSError **)error;
- (BOOL)closeWithError:(NSError **)error;

@end
