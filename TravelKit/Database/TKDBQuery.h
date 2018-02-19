/*
 *  TKDBQuery.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface TKDBQuery : NSObject

+ (instancetype)queryWithTable:(NSString *)tableName;

@property (strong, nonatomic, readonly) NSString *sqlString;

@end
