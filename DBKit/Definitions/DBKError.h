/*
 *  DBKError.h
 *  Created on 25/Nov/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <DBKit/DBKDefines.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  DBKErrorDomain
 *
 *  Discussion:
 *    The domain of errors returned from DBKit.
 */
DBK_EXTERN NSString *const DBKErrorDomain;

/*
 *  DBKSQLiteErrorDomain
 *
 *  Discussion:
 *    The domain of SQLite errors.
 */
DBK_EXTERN NSString *const DBKSQLiteErrorDomain;

/*
 *  DBKError
 *
 *  Discussion:
 *    The code of errors returned from DBKit.
 */
typedef NS_ENUM(NSInteger, DBKError) {
    DBKErrorUnknown = 0,
    DBKErrorInvalidPath = 1,
    DBKErrorNoSuchFile = 2,
    DBKErrorNoReadPermission = 3,
    DBKErrorNoWritePermission = 4,
    DBKErrorBadDatabase = 5,
    DBKErrorDatabaseBusy = 6
};

NS_ASSUME_NONNULL_END
