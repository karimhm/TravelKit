/*
 *  TKDatabase.h
 *  Created on 13/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDBQuery.h"
#import "TKDBCursor.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, TKDBOptions) {
    TKDBOptionsNone              = 0,
    TKDBOptionsOpenReadOnly      = 1 << 0,
    TKDBOptionsOpenReadWrite     = 1 << 1,
    TKDBOptionsCreate            = 1 << 2
};

@class TKDatabase;
@protocol TKDatabaseDelegate <NSObject>
@required

- (void)database:(TKDatabase *)database didFailWithError:(NSError *)error;
- (BOOL)databaseShouldHandleBusy:(TKDatabase *)database;

@end

@interface TKDatabase : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithURL:(NSURL *)url;

- (BOOL)open;
- (BOOL)openReadWrite;
- (BOOL)openWithOptions:(TKDBOptions)options error:(NSError **)error;
- (BOOL)close;

@property (nonatomic, readonly, getter=isValid) BOOL valid;
@property (nonatomic, readonly, getter=isOpen) BOOL open;

@property (nonatomic) NSInteger busyTimeout;

@property (weak, nonatomic) id<TKDatabaseDelegate> delegate;

- (TKDBCursor *)executeQuery:(TKDBQuery *)query;
- (TKDBCursor *)executeQuery:(TKDBQuery *)query error:(NSError **)error;
- (TKDBCursor *)executeQueryWithFormat:(NSString *)format, ...;

- (BOOL)tableExists:(NSString*)tableName;
- (BOOL)columnExists:(NSString*)columnName inTableWithName:(NSString*)tableName;

@end

NS_ASSUME_NONNULL_END
