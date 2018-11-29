/*
 *  NSError+TravelKit.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "NSError+TravelKit.h"
#import "TKError.h"

@implementation NSError (TravelKit)

#pragma mark - TravelKit Error

+ (instancetype)tk_badDatabaseError {
    return [NSError errorWithDomain:TKErrorDomain code:TKErrorBadDatabase userInfo:nil];
}

@end
