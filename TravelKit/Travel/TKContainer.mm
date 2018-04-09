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
#import <objc/objc.h>
#import <map>

typedef std::map<int64_t, id> TKObjcMap;

@implementation TKContainer {
    TKDatabase *_db;
    NSURL *_url;
    TKObjcMap _stationsMap;
}

#pragma mark - Initialization

- (instancetype)initWithPath:(NSString *)path error:(NSError **)error {
    return [self initWithURL:[NSURL fileURLWithPath:path] error:error];
}

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error {
    if (self = [super init]) {
        _url = url;
        _db = [[TKDatabase alloc] initWithURL:url];
        
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

#pragma mark - Fetch

- (void)fetchStationsMatchingName:(NSString *)name limit:(NSInteger)limit completion:(TKStationFetchHandler)completion {
    TKStatement *statement = [[TKStatement alloc] initWithDatabase:_db format:@"SELECT * FROM %@ WHERE %@ LIKE ?1 LIMIT ?2", kTKTableStation, kTKColumnName];
    NSError *error = nil;
    
    if (![statement prepareWithError:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![statement bindString:[NSString stringWithFormat:@"%@%%", name] index:1 error:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![statement bindInteger:limit index:2 error:&error]) {
        completion(nil, error);
        return;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (id<TKDBRow> row in statement) {
        TKStation *station = _stationsMap[[row int64ForColumn:kTKColumnID]];
        
        if (!station) {
            station = [[TKStation alloc] initWithRow:row];
            _stationsMap[[row int64ForColumn:kTKColumnID]] = station;
        }
        
        [result addObject:station];
    }
    
    completion(result, nil);
}

#pragma mark -

- (void)dealloc {
    if (_db.isOpen) {
        [_db close];
    }
    
    _db.delegate = nil;
    _db = nil;
    _url = nil;
}

@end
