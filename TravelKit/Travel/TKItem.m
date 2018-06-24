/*
 *  TKItem.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKItem.h"
#import "TKItem_Private.h"

@implementation TKItem
@synthesize valid = _valid;

- (instancetype)initWithRow:(id <TKDBRow>)row manager:(id <TKItemManager>)manager {
    if (self = [super init]) {
        _identifier = (TKItemID)[row int64ForColumn:kTKColumnID];
        _valid = true;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object != nil && [object class] == [self class]) {
        return [self identifier] == [(__kindof TKItem *)object identifier];
    } else {
        return false;
    }
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

- (NSString *)tableName {
    return nil;
}

+ (TKDBVerifySet *)requiredTablesAndColumns {
    return @{};
}

@end
