/*
 *  TKDBVerify.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKDatabase.h>

typedef NSDictionary <NSString*, NSArray <NSString*> *> TKDBVerifySet;

@protocol TKDBVerify <NSObject>

+ (BOOL)isDatabaseValid:(TKDatabase *)database;
+ (TKDBVerifySet *)requiredTablesAndColumns;

@end
