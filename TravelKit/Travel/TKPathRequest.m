/*
 *  TKPathRequest.m
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKPathRequest.h"

@implementation TKPathRequest

+ (instancetype)requestWithSource:(TKStation *)source destination:(TKStation *)destination {
    TKPathRequest *request = [TKPathRequest new];
    request.source = source;
    request.destination = destination;
    
    return request;
}

- (void)dealloc {
    _source = nil;
    _destination = nil;
    _departureDate = nil;
}

@end
