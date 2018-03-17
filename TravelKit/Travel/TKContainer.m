/*
 *  TKContainer.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKContainer.h"
#import "TKDatabase.h"
#import "TKStatement.h"
#import "TKItem_Private.h"
#import "TKConstants_Private.h"
#import "NSError+TravelKit.h"

@implementation TKContainer {
    TKDatabase *_db;
    NSURL *_url;
}

#pragma mark - Initialization

- (instancetype)initWithPath:(NSString *)path error:(NSError **)error {
    return [self initWithURL:[NSURL fileURLWithPath:path] error:error];
}

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error {
    if (self = [super init]) {
        _url = url;
        _db = [[TKDatabase alloc] initWithURL:url];
        _stations = [[NSMutableSet alloc] initWithCapacity:0];
        
        [self openDatabase:error];
    }
    return self;
}

#pragma mark - Loading

- (void)openDatabase:(NSError **)error {
    if ([_db openWithOptions:TKDBOptionsOpenReadOnly error:error]) {
        if ([self verifyDatabase:_db]) {
            _valid = true;
        } else {
            *error = [NSError tk_badDatabaseError];
        }
    }
}

- (BOOL)verifyDatabase:(TKDatabase *)database {
    return [TKStation isDatabaseValid:database];
}

- (void)loadStations {
    TKStatement *statement = [[TKStatement alloc] initWithDatabase:_db format:@"select * from %@", kTKTableStation];
    
    if ([statement prepareWithError:nil]) {
        for (id<TKDBRow> row in statement) {
            TKStation *station = [[TKStation alloc] initWithRow:row];
            [(NSMutableSet *)_stations addObject:station];
        }
    }
    
    [statement close];
}

#pragma mark -

- (void)dealloc {
    [(NSMutableSet *)_stations removeAllObjects];
    
    if (_db.isOpen) {
        [_db close];
    }
    
    _stations = nil;
    _db.delegate = nil;
    _db = nil;
    _url = nil;
}

@end
