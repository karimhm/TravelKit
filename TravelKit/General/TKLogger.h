/*
 *  TKLogger.h
 *  Created on 25/Oct/2019.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <TravelKit/TKDefines.h>

TK_EXTERN void TKLogDefault(NSString *message, ...) NS_FORMAT_FUNCTION(1, 2);
TK_EXTERN void TKLogInfo(NSString *message, ...) NS_FORMAT_FUNCTION(1, 2);
TK_EXTERN void TKLogError(NSString *message, ...) NS_FORMAT_FUNCTION(1, 2);
TK_EXTERN void TKLogFault(NSString *message, ...) NS_FORMAT_FUNCTION(1, 2);
TK_EXTERN void TKLogDebug(NSString *message, ...) NS_FORMAT_FUNCTION(1, 2);
