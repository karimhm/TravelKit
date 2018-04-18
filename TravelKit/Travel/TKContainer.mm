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
#import "TKContainer_Private.h"
#import "TKConstants_Private.h"
#import "TKPathResponse_Private.h"
#import "TKDistanceFunction.h"
#import "TKLineContainsFunction.h"
#import "TKStationIndexFunction.h"
#import "TKDepartureWayFunction.h"
#import "TKDepartureAvailableFunction.h"
#import "NSError+TravelKit.h"
#import <CoreLocation/CoreLocation.h>
#import <map>

typedef std::map<int64_t, id> TKObjcMap;
typedef std::map<NSUInteger, TKObjcMap> TKCacheMap;

@implementation TKContainer {
    TKDatabase *_db;
    NSURL *_url;
    TKCacheMap _cache;
    TKStatement *_fetchStStmt;
    TKStatement *_fetchStMtchNameStmt;
    TKStatement *_fetchStNearLocStmt;
    TKStatement *_fetchPathStmt;
}

#pragma mark - Initialization

- (instancetype)initWithPath:(NSString *)path error:(NSError **)error {
    return [self initWithURL:[NSURL fileURLWithPath:path] error:error];
}

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error {
    if (self = [super init]) {
        _url = url;
        _db = [[TKDatabase alloc] initWithURL:url];
        
        BOOL status = [self openDatabase:error];
        
        if (status == true) {
            status = [self addFunctions:error];
        }
        
        if (status == true) {
            status = [self prepareStatements:error];
        }
        
        _valid = status;
    }
    return self;
}

#pragma mark - Loading

- (BOOL)openDatabase:(NSError **)error {
    if ([_db openWithOptions:TKDBOptionsOpenReadOnly error:error]) {
        if ([self verifyDatabase:_db]) {
            return true;
        } else {
            *error = [NSError tk_badDatabaseError];
        }
    }
    
    return false;
}

- (BOOL)verifyDatabase:(TKDatabase *)database {
    BOOL status = [TKStation isDatabaseValid:database];
    
    if (status) {
        status = [TKDeparture isDatabaseValid:database];
    }
    
    return status;
}

- (BOOL)addFunctions:(NSError **)error {
    BOOL status = true;
    
    if (!(status = [_db addFunction:TKGetDistanceFunction() error:error])) {
        goto cleanup;
    }
    
    if (!(status = [_db addFunction:TKGetLineContainsFunction() error:error])) {
        goto cleanup;
    }
    
    if (!(status = [_db addFunction:TKGetStationIndexFunction() error:error])) {
        goto cleanup;
    }
    
    if (!(status = [_db addFunction:TKGetDepartureWayFunction() error:error])) {
        goto cleanup;
    }
    
    if (!(status = [_db addFunction:TKGetDepartureAvailableFunction() error:error])) {
        goto cleanup;
    }
    
cleanup:
    return status;
}

- (BOOL)prepareStatements:(NSError **)error {
    BOOL status = true;
    
    _fetchStStmt = [[TKStatement alloc] initWithDatabase:_db format:@"SELECT * FROM %@ WHERE %@ = ?1", kTKTableStation, kTKColumnID];
    _fetchStMtchNameStmt = [[TKStatement alloc] initWithDatabase:_db format:@"SELECT * FROM %@ WHERE %@ LIKE ?1 LIMIT ?2", kTKTableStation, kTKColumnName];
    _fetchStNearLocStmt = [[TKStatement alloc] initWithDatabase:_db format:@"SELECT * FROM %@ GROUP BY tkDistance(?1, ?2, latitude, longitude) LIMIT ?3", kTKTableStation];
    _fetchPathStmt = [[TKStatement alloc] initWithDatabase:_db format:@""
                      "with PossibleLines as ("
                        "select stations, id, "
                        "tkStationIndex(stations, ?1) as sIndex, "
                        "tkStationIndex(stations, ?2) as dIndex "
                        "from Line where tkLineContains(stations, ?1, ?2)"
                      ")"
                      "select * from [%@] join [PossibleLines] "
                      "where "
                        "[%@].lineId = [PossibleLines].id "
                      "and "
                        "[%@].way = tkDepartureWay(sIndex, dIndex) "
                      "and "
                        "tkDepartureAvailable(stops, ?3, sIndex, dIndex)", kTKTableDeparture, kTKTableDeparture, kTKTableDeparture];

    
    if (!(status = [_fetchStStmt prepareWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchStMtchNameStmt prepareWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchStNearLocStmt prepareWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchPathStmt prepareWithError:error])) {
        goto cleanup;
    }
    
cleanup:
    return status;
    
}

#pragma mark - Fetch

- (TKStation *)fetchStationWithId:(int64_t)stationId error:(NSError **)error {
    TKStation *station = _cache[kTKTableStation.hash][stationId];
    
    if (!station) {
        if (![_fetchStStmt clearAndResetWithError:error]) {
            return nil;
        }
        
        if (![_fetchStStmt bindInteger:stationId index:1 error:error]) {
            return nil;
        }
        
        station = [[TKStation alloc] initWithRow:[_fetchStStmt next] manager:self];
    }
    
    return station;
}

- (void)fetchStationsMatchingName:(NSString *)name limit:(NSInteger)limit completion:(TKStationFetchHandler)completion {
    NSError *error = nil;
    
    if (![_fetchStMtchNameStmt clearAndResetWithError:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchStMtchNameStmt bindString:[NSString stringWithFormat:@"%@%%", name] index:1 error:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchStMtchNameStmt bindInteger:limit index:2 error:&error]) {
        completion(nil, error);
        return;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (id<TKDBRow> row in _fetchStMtchNameStmt) {
        TKStation *station = [self itemWithIdentifier:[row int64ForColumn:kTKColumnID] table:kTKTableStation error:nil];
        
        if (!station) {
            station = [[TKStation alloc] initWithRow:row manager:self];
            [self insertItem:station];
        }
        
        [result addObject:station];
    }
    
    completion(result, nil);
}

- (void)fetchStationsNearLocation:(CLLocation *)location limit:(NSInteger)limit completion:(TKStationFetchHandler)completion {
    NSError *error = nil;
    
    if (![_fetchStNearLocStmt clearAndResetWithError:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchStNearLocStmt bindDouble:location.coordinate.latitude index:1 error:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchStNearLocStmt bindDouble:location.coordinate.longitude index:2 error:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchStNearLocStmt bindInteger:limit index:3 error:&error]) {
        completion(nil, error);
        return;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (id<TKDBRow> row in _fetchStNearLocStmt) {
        TKStation *station = [self itemWithIdentifier:[row int64ForColumn:kTKColumnID] table:kTKTableStation error:nil];
        
        if (!station) {
            station = [[TKStation alloc] initWithRow:row manager:self];
            [self insertItem:station];
        }
        
        [result addObject:station];
    }
    
    completion(result, nil);
}

- (void)fetchPathWithRequest:(TKPathRequest *)request completion:(TKPathRequestHandler)completion {
    NSError *error = nil;
    
    if (![_fetchPathStmt clearAndResetWithError:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchPathStmt bindInteger:request.source.identifier index:1 error:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchPathStmt bindInteger:request.destination.identifier index:2 error:&error]) {
        completion(nil, error);
        return;
    }
    
    NSInteger daystamp = ((NSInteger)request.departureDate.timeIntervalSince1970 % 86400);
    if (![_fetchPathStmt bindInteger:daystamp index:3 error:&error]) {
        completion(nil, error);
        return;
    }
    
    NSMutableArray *departures = [[NSMutableArray alloc] init];
    
    for (id<TKDBRow> row in _fetchPathStmt) {
        TKDeparture *departure = [[TKDeparture alloc] initWithRow:row manager:self];
        [departures addObject:departure];
    }
    
    TKPathResponse *response = [[TKPathResponse alloc] initWithDepartures:departures source:request.source destination:request.destination];
    completion(response, nil);
}

#pragma mark - Caching

- (void)insertItem:(__kindof TKItem *)item {
    if (!_cache.count([item tableName].hash)) {
        _cache[[item tableName].hash] = {};
    }
    
    _cache[[item tableName].hash][item.identifier] = item;
}

- (void)deleteItem:(__kindof TKItem *)item {
    _cache[[item tableName].hash][item.identifier] = nullptr;
}

- (__kindof TKItem *)itemWithIdentifier:(int64_t)identifier table:(NSString *)table error:(NSError **)error {
    if ([table isEqualToString:kTKTableStation]) {
        return [self fetchStationWithId:identifier error:error];
    } else {
        return nil;
    }
}

#pragma mark -

- (void)dealloc {
    if (_db.isOpen) {
        [_db close];
    }
    
    _cache.clear();[_fetchStStmt close];
    [_fetchStMtchNameStmt close];
    [_fetchStNearLocStmt close];
    [_fetchPathStmt close];
    
    _db.delegate = nil;
    _db = nil;
    _url = nil;
    
    _fetchStStmt = nil;
    _fetchStMtchNameStmt = nil;
    _fetchStNearLocStmt = nil;
    _fetchPathStmt = nil;
}

@end
