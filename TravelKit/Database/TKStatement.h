/*
 *  TKStatement.h
 *  Created on 4/Mar/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDatabase.h"
#import "TKDBRow.h"
#import <sqlite3.h>

@interface TKStatement : NSEnumerator

- (instancetype)initWithDatabase:(TKDatabase *)database text:(NSString *)text;
- (instancetype)initWithDatabase:(TKDatabase *)database format:(NSString *)format, ...;

- (BOOL)bindDouble:(double)value index:(NSInteger)index error:(NSError **)error;
- (BOOL)bindInteger:(NSInteger)value index:(NSInteger)index error:(NSError **)error;
- (BOOL)bindString:(NSString *)value index:(NSInteger)index error:(NSError **)error;
- (BOOL)bindData:(NSData *)value index:(NSInteger)index error:(NSError **)error;
- (BOOL)bindNullWithIndex:(NSInteger)index error:(NSError **)error;

@property (nonatomic, readonly) NSInteger columnCount;
@property (nonatomic, readonly) NSArray <NSString *> *columnNames;

@property (nonatomic, readonly, getter=isReadOnly) BOOL readOnly;
@property (nonatomic, readonly, getter=isbusy) BOOL busy;
@property (nonatomic, readonly, getter=isClosed) BOOL closed; 

@property (nonatomic, readonly) sqlite3_stmt* sqlitePtr;

- (BOOL)prepareWithError:(NSError **)error;
- (BOOL)executeWithError:(NSError **)error;

- (id<TKDBRow>)next;
- (BOOL)hasNext;
- (BOOL)clearBindings;
- (BOOL)reset;
- (BOOL)close;

@end
