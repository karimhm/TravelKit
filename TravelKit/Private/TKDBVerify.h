/*
 *  TKDBVerify.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKDatabase.h>

@protocol TKDBVerify <NSObject>

+ (BOOL)isDatabaseValid:(TKDatabase *)database;
+ (NSString *)databaseTableName;
+ (NSArray <NSString *> *)tableRequiredColumns;

@end
