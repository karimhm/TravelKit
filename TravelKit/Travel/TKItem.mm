/*
 *  TKItem.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKItem.h"
#import "TKItem_Private.h"
#import "TKItem_Core.h"

using namespace tk;

@implementation TKItem
@synthesize valid = _valid;

- (instancetype)initWithRow:(id <DBKRow>)row manager:(id <TKItemManager>)manager {
    if (self = [super init]) {
        _identifier = (TKItemID)[row int64ForColumn:kTKColumnID];
        _valid = true;
    }
    return self;
}

-(instancetype)initWithStatement:(Ref<Statement>)statement {
    if (self = [super init]) {
        _identifier = (*statement)["id"].int64Value();
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

+ (BOOL)isDatabaseValid:(DBKDatabase *)database {
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

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    TKItem *item = [[[self class] allocWithZone:zone] init];
    item->_identifier = self.identifier;
    item->_valid = self.valid;
    
    return item;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    TK_ENCODE_INT64(aCoder, identifier);
    TK_ENCODE_BOOL(aCoder, valid);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        TK_DECODE_INT64(aDecoder, identifier);
        TK_DECODE_BOOL(aDecoder, valid);
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return true;
}

@end
