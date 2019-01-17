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
 *    The domain of SQLite errors.
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
    TKErrorBadDatabase = 1,
    TKErrorInternalDatabaseError = 2
};

NS_ASSUME_NONNULL_END
