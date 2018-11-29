/*
 *  TKDBVerify.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <DBKit/DBKDatabase.h>

typedef NSDictionary <NSString*, NSArray <NSString*> *> TKDBVerifySet;

@protocol TKDBVerify <NSObject>

+ (BOOL)isDatabaseValid:(DBKDatabase *)database;
+ (TKDBVerifySet *)requiredTablesAndColumns;

@end
