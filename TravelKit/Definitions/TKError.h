/*
 *  TKError.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKDefines.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  TKErrorDomain
 *
 *  Discussion:
 *    The domain of erors returned from TravelKit.
 */
TK_EXTERN NSString *const TKErrorDomain;

/*
 *  TKSQLiteErrorDomain
 *
 *  Discussion:
 *    The domain of SQLite erors.
 */
TK_EXTERN NSString *const TKSQLiteErrorDomain;

/*
 *  TKError
 *
 *  Discussion:
 *    The code of errors returned from TravelKit.
 */
typedef NS_ENUM(NSInteger, TKError) {
    TKErrorUnknown = 0,
    TKErrorInvalidPath = 1,
    TKErrorNoSuchFile = 2,
    TKErrorNoReadPermission = 3,
    TKErrorNoWritePermission = 4,
    TKErrorBadDatabase = 5,
    TKErrorDatabaseBusy = 6
};

NS_ASSUME_NONNULL_END
