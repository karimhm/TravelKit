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
    TKDBVerifySet *set = [self requiredTablesAndColumns];
    BOOL valid = true;
    
    if (set) {
        for (id tableName in set.keyEnumerator) {
            if ([database tableExists:tableName]) {
                for (id column in [set valueForKey:tableName]) {
                    if (![database columnExists:column inTableWithName:tableName]) {
                        valid = false;
                        break;
                    }
                }
            } else {
                valid = false;
                break;
            }
        }
    } else {
        valid = false;
    }
    
    return valid;
}

+ (TKDBVerifySet *)requiredTablesAndColumns {
    return @{};
}

@end
