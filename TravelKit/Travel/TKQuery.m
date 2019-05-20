/*
 *  TKQuery.m
 *  Created on 19/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKQuery.h"
#import "TKQuery_Private.h"

TKOrderProperty const TKOrderByName = @"name";

@implementation TKQuery {
    NSString *_language;
    CLLocation *_location;
    BOOL _idSet;
}

- (void)setItemID:(TKItemID)itemID {
    _itemID = itemID;
    _idSet = true;
}

- (void)setLanguage:(NSString *)language {
    _language = language;
}

- (NSString *)language {
    return _language;
}

- (void)setLocation:(CLLocation *)location {
    _location = location;
}

- (CLLocation *)location {
    return _location;
}

- (BOOL)idSet {
    return _idSet;
}

@end
