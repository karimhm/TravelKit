/*
 *  TKCursor.m
 *  Created on 19/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKCursor.h"
#import "TKCursor_Private.h"
#import "Database.h"

using namespace tk;

@implementation TKCursor

+ (instancetype)cursorWithDatabase:(tk::Ref<tk::Database>)database query:(TKQuery *)query error:(NSError **)error {
    return [[[self class] alloc] initWithDatabase:database query:query error:error];
}

- (instancetype)initWithDatabase:(tk::Ref<tk::Database>)database query:(TKQuery *)query error:(NSError **)error {
    if (self = [super init]) {
        _database = database;
        _fetchResult = [[NSMutableArray alloc] init];
        
        if (![self prepareWithQuery:query error:error]) {
            _database = nil;
            _fetchResult = nil;
            return nil;
        }
    }
    return self;
}

- (void)fetchAllWithCompletion:(void (^) (NSArray <TKItem *> * __nullable result, NSError * __nullable error))completion {
    NSError *fetchError = nil;
    
    if (_result) {
        completion(_result, nil);
    } else if ([self fetchAllWithError:&fetchError]) {
        completion(_result, nil);
    } else {
        completion(nil, fetchError);
    }
}

- (nullable TKItem *)fetchOneWithError:(NSError **)error {
    id object = [self nextWithError:error];
    self.completed = true;
    return object;
}

- (nullable id)nextWithError:(NSError **)error {
    Status status = _statement->next();
    
    if (status.isRow()) {
        id object = [self createObjectWithStatement:_statement];
        [self.fetchResult addObject:object];
        
        return object;
    } else if (status.isDone()) {
        self.completed = true;
    } else {
        TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    return nil;
}

- (nullable TKItem *)next {
    return [self nextWithError:nil];
}

- (TKItem *)nextObject {
    return [self next];
}

- (NSArray *)result {
    if (!_result) {
        [self fetchAllWithError:nil];
    }
    
    return _result;
}

- (nullable id)createObjectWithStatement:(Ref<Statement>)statement {
    return nil;
}

- (void)setCompleted:(BOOL)completed {
    _completed = completed;
    
    if (completed) {
        _result = _fetchResult;
    }
}

- (BOOL)prepareWithQuery:(TKQuery *)query error:(NSError **)error {
    return false;
}

- (BOOL)fetchAllWithError:(NSError **)error {
    Status status = Status();
    
    while ((status = _statement->next()).isRow()) {
        [self.fetchResult addObject:[self createObjectWithStatement:_statement]];
    }
    
    if (status.isDone()) {
        self.completed = true;
        return true;
    } else {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
}

- (BOOL)close {
    return _statement->close().isOK();
}

- (void)dealloc {
    [self close];
    
    _result = nil;
    _fetchResult = nil;
}

@end
