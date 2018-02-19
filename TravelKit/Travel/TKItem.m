/*
 *  TKItem.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKItem.h"
#import "TKItem_Private.h"

@implementation TKItem

- (instancetype)initWithRow:(id <TKDBRow>)row {
    return [self init];
}

#pragma mark - TKDBVerify

+ (BOOL)isDatabaseValid:(TKDatabase *)database {
    NSString *tableName = [self databaseTableName];
    
    if (tableName && [database tableExists:tableName]) {
        for (id column in [self tableRequiredColumns]) {
            if (![database columnExists:column inTableWithName:tableName]) {
                return false;
                break;
            }
        }
    } else {
        return false;
    }
    
    return true;
}

+ (NSString *)databaseTableName {
    return nil;
}

+ (NSArray <NSString *> *)tableRequiredColumns {
    return @[];
}

@end
