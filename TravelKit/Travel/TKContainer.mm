/*
 *  TKContainer.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKContainer.h"
#import "TKDatabase.h"
#import "TKAvailability.h"
#import "TKStatement.h"
#import "TKUtilities.h"
#import "TKItem_Private.h"
#import "TKContainer_Private.h"
#import "TKConstants_Private.h"
#import "TKPathResponse_Private.h"
#import "TKDistanceFunction.h"
#import "TKLineContainsFunction.h"
#import "TKStationIndexFunction.h"
#import "TKDepartureWayFunction.h"
#import "TKDepartureAvailableFunction.h"
#import "TKMatchFunction.h"
#import "NSError+TravelKit.h"
#import <CoreLocation/CoreLocation.h>
#import <map>

typedef std::map<int64_t, id> TKObjcMap;
typedef std::map<NSUInteger, TKObjcMap> TKCacheMap;

@implementation TKContainer {
    TKDatabase *_db;
    NSURL *_url;
    TKCacheMap _cache;
    NSMutableArray *_availability;
    TKStatement *_fetchStStmt;
    TKStatement *_fetchStMtchNameStmt;
    TKStatement *_fetchStNearLocStmt;
    TKStatement *_fetchAvailabilityStmt;
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
        _availability = [[NSMutableArray alloc] init];
        
        BOOL status = [self openDatabase:error];
        
        if (status == true) {
            status = [self addFunctions:error];
        }
        
        if (status == true) {
            status = [self prepareStatements:error];
        }
        
        if (status == true) {
            status = [self loadAvailability];
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
    
    if (status) {
        status = [TKAvailability isDatabaseValid:database];
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
    
    if (!(status = [_db addFunction:TKGetMatchFunction() error:error])) {
        goto cleanup;
    }
    
cleanup:
    return status;
}

- (BOOL)closeDatabase {
    NSError *error = nil;
    if ([self closeStatements:&error]) {
        _valid = false;
        return [_db close];
    }else {
        return false;
    }
}

- (BOOL)prepareStatements:(NSError **)error {
    BOOL status = true;
    
    _fetchStStmt = [[TKStatement alloc] initWithDatabase:_db format:@"SELECT * FROM %@ WHERE %@ = ?1", kTKTableStation, kTKColumnID];
    _fetchStMtchNameStmt = [[TKStatement alloc] initWithDatabase:_db format:@"SELECT * FROM %@ WHERE %@ LIKE ?1 AND %@ != ?2 LIMIT ?3", kTKTableStation, kTKColumnName, kTKColumnID];
    _fetchStNearLocStmt = [[TKStatement alloc] initWithDatabase:_db format:@"SELECT * FROM %@ GROUP BY tkDistance(?1, ?2, latitude, longitude) LIMIT ?3", kTKTableStation];
    _fetchAvailabilityStmt = [[TKStatement alloc] initWithDatabase:_db format:@"SELECT * FROM %@", kTKTableAvailability];
    _fetchPathStmt = [[TKStatement alloc] initWithDatabase:_db format:@""
                      "WITH PossibleLines as ("
                        "SELECT stations, id, "
                        "tkStationIndex(stations, ?1) as sIndex, "
                        "tkStationIndex(stations, ?2) as dIndex "
                        "FROM Line WHERE tkLineContains(stations, ?1, ?2)"
                      ")"
                      "SELECT *, tkMatch([Departure].availabilityId, ?3) as available "
                      "FROM [%@] JOIN [PossibleLines] "
                      "WHERE "
                        "[%@].lineId = [PossibleLines].id "
                      "AND "
                        "[%@].way = tkDepartureWay(sIndex, dIndex) "
                      "AND "
                        "tkDepartureAvailable(stops, ?4, sIndex, dIndex)", kTKTableDeparture, kTKTableDeparture, kTKTableDeparture];

    if (!(status = [_fetchStStmt prepareWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchStMtchNameStmt prepareWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchStNearLocStmt prepareWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchAvailabilityStmt prepareWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchPathStmt prepareWithError:error])) {
        goto cleanup;
    }
    
cleanup:
    return status;
    
}

- (BOOL)closeStatements:(NSError **)error {
    BOOL status = true;
    
    if (!(status = [_fetchStStmt closeWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchStMtchNameStmt closeWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchStNearLocStmt closeWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchAvailabilityStmt closeWithError:error])) {
        goto cleanup;
    }
    
    if (!(status = [_fetchPathStmt closeWithError:error])) {
        goto cleanup;
    }
    
cleanup:
    return status;
}

- (BOOL)loadAvailability {
    for (id<TKDBRow> row in _fetchAvailabilityStmt) {
        TKAvailability *availability = [[TKAvailability alloc] initWithRow:row manager:self];
        [_availability addObject:availability];
    }
    return (_availability.count > 0);
}

#pragma mark - Fetch

- (TKStation *)fetchStationWithId:(TKItemID)stationId error:(NSError **)error {
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

- (void)fetchStationsMatchingName:(NSString *)name limit:(TKInt)limit completion:(TKStationFetchHandler)completion {
    [self fetchStationsMatchingName:name excluding:-1 limit:limit completion:completion];
}

- (void)fetchStationsMatchingName:(NSString *)name excluding:(TKItemID)stationId limit:(TKInt)limit completion:(TKStationFetchHandler)completion {
    NSError *error = nil;
    
    if (![_fetchStMtchNameStmt clearAndResetWithError:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchStMtchNameStmt bindString:[NSString stringWithFormat:@"%@%%", name] index:1 error:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchStMtchNameStmt bindInteger:stationId index:2 error:&error]) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchStMtchNameStmt bindInteger:limit index:3 error:&error]) {
        completion(nil, error);
        return;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (id<TKDBRow> row in _fetchStMtchNameStmt) {
        TKStation *station = [self itemWithIdentifier:(TKItemID)[row int64ForColumn:kTKColumnID] table:kTKTableStation error:nil];
        
        if (!station) {
            station = [[TKStation alloc] initWithRow:row manager:self];
            [self insertItem:station];
        }
        
        [result addObject:station];
    }
    
    completion(result, nil);
}

- (void)fetchStationsNearLocation:(CLLocation *)location limit:(TKInt)limit completion:(TKStationFetchHandler)completion {
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
        TKStation *station = [self itemWithIdentifier:(TKItemID)[row int64ForColumn:kTKColumnID] table:kTKTableStation error:nil];
        
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
    
    NSData *availabilityData = [self availabilityForDate:request.departureDate];
    
    if (!availabilityData) {
        completion(nil, error);
        return;
    }
    
    if (![_fetchPathStmt bindData:availabilityData index:3 error:&error]) {
        completion(nil, error);
        return;
    }
    
    TKTimeInfo timeInfo = TKTimeInfoCreate(request.departureDate.timeIntervalSince1970);
    
    if (![_fetchPathStmt bindInteger:TKTimeInfoGetDaystamp(timeInfo) index:4 error:&error]) {
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


- (NSData *)availabilityForDate:(NSDate *)date {
    NSData *availabilityData = nil;
    
    int32_t availabilities[_availability.count];
    int32_t index = 0;
    
    /* Add the available ones */
    for (TKAvailability *availability in _availability) {
        if ([availability availableAtDate:date]) {
            availabilities[index] = (int32_t)availability.identifier;
            index++;
        }
    }
    
    /* Bubble sort the ids */
    for (int32_t i = index; i >= 0; i--) {
        for (int32_t j = 1; j <= i; j++) {
            if (availabilities[j-1] > availabilities[j]) {
                int32_t temp = availabilities[j-1];
                availabilities[j-1] = availabilities[j];
                availabilities[j] = temp;
            }
        }
    }
    
    if (index > 0) {
        availabilityData = [NSData dataWithBytes:&availabilities length:index * sizeof(int32_t)];
    }
    
    return availabilityData;
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

- (__kindof TKItem *)itemWithIdentifier:(TKItemID)identifier table:(NSString *)table error:(NSError **)error {
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
    
    _cache.clear();
    
    [_fetchStStmt close];
    [_fetchStMtchNameStmt close];
    [_fetchStNearLocStmt close];
    [_fetchPathStmt close];
    [_fetchAvailabilityStmt close];
    
    _db.delegate = nil;
    _db = nil;
    _url = nil;
    _availability = nil;
    
    _fetchStStmt = nil;
    _fetchStMtchNameStmt = nil;
    _fetchStNearLocStmt = nil;
    _fetchPathStmt = nil;
    _fetchAvailabilityStmt = nil;
}

@end
