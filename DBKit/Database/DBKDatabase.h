/*
 *  DBKDatabase.h
 *  Created on 13/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <DBKit/DBKFunction.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, DBKOptions) {
    DBKOptionsNone              = 0,
    DBKOptionsOpenReadOnly      = 1 << 0,
    DBKOptionsOpenReadWrite     = 1 << 1,
    DBKOptionsCreate            = 1 << 2
};

@class DBKDatabase;
@protocol DBKDatabaseDelegate <NSObject>
@required

- (void)database:(DBKDatabase *)database didFailWithError:(NSError *)error;
- (BOOL)databaseShouldHandleBusy:(DBKDatabase *)database;

@end

@interface DBKDatabase : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithURL:(NSURL *)url;

- (BOOL)open;
- (BOOL)openReadWrite;
- (BOOL)openWithOptions:(DBKOptions)options error:(NSError **)error;
- (BOOL)close;

@property (nonatomic, readonly, getter=isValid) BOOL valid;
@property (nonatomic, readonly, getter=isOpen) BOOL open;

@property (nonatomic, readonly) sqlite3* sqlitePtr;

@property (nonatomic) DBKInt busyTimeout;

@property (weak, nonatomic) id<DBKDatabaseDelegate> delegate;

- (BOOL)tableExists:(NSString*)tableName;
- (BOOL)columnExists:(NSString*)columnName inTableWithName:(NSString*)tableName;

- (BOOL)addFunction:(DBKFunctionContext)function error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
