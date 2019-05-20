/*
 *  TKItem.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKItem.h"
#import "TKItem_Core.h"

using namespace tk;

@implementation TKItem
@synthesize valid = _valid;

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
