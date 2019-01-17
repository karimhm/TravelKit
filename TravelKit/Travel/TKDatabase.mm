/*
 *  TKDatabase.mm
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDatabase.h"
#import "NSError+TravelKit.h"
#import "TKDistanceFunction.h"
#import "TKItem_Core.h"
#import "Database.h"
#import "Statement.h"
#import "TKError.h"

using namespace tk;

@implementation TKDatabase {
    Ref<Database> _db;
    Ref<Statement> _fetchProperties;
    Ref<Statement> _fetchStopPlaceById;
    Ref<Statement> _fetchStopPlacesByName;
    Ref<Statement> _fetchStopPlacesByLocation;
}

#pragma mark - Initialization

- (instancetype)initWithPath:(NSString *)path {
    return [self initWithURL:[NSURL fileURLWithPath:path]];
}

- (instancetype)initWithURL:(NSURL *)url {
    if (!url) {
        return nil;
    } else if (self = [super init]) {
        _url = url;
        _properties = [[NSMutableDictionary alloc] init];
        
        _db = makeRef<Database>([url fileSystemRepresentation]);
    }
    return self;
}

#pragma mark - Loading

- (BOOL)openDatabase:(NSError **)error {
    BOOL status = _db->open(Options::OpenReadOnly).isOK();
    
    if (status) {
        if (![self addFunctions:nil]) {
            return false;
        }
        
        if (![self prepareStatements:error]) {
            return false;
        }
        
        if (![self loadProperties:error]) {
            return false;
        }
    } else {
        *error = [NSError tk_badDatabaseError];
    }
    
    _valid = status;
    return status;
}

- (BOOL)prepareStatements:(NSError **)error {
    BOOL status = true;
    
    _fetchProperties = makeRef<Statement>(_db, "SELECT * FROM Properties");
    _fetchStopPlaceById = makeRef<Statement>(_db, "SELECT * FROM StopPlace WHERE id = :id");
    _fetchStopPlacesByName = makeRef<Statement>(_db, "SELECT * FROM StopPlace WHERE name LIKE :name LIMIT :limit");
    _fetchStopPlacesByLocation = makeRef<Statement>(_db, "SELECT * FROM StopPlace GROUP BY tkDistance(:latitude, :longitude, latitude, longitude) LIMIT :limit");
    
    if (!_fetchStopPlaceById->prepare().isOK()) {
        *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        status = false;
        goto cleanup;
    }
    
    if (!_fetchStopPlacesByName->prepare().isOK()) {
        *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        status = false;
        goto cleanup;
    }
    
    if (!_fetchStopPlacesByLocation->prepare().isOK()) {
        *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        status = false;
        goto cleanup;
    }
    
    if (!_fetchProperties->prepare().isOK()) {
        *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        status = false;
        goto cleanup;
    }
    
cleanup:
    return status;
}

- (BOOL)addFunctions:(NSError **)error {
    return _db->addFunction([self dbkContextTK:TKGetDistanceFunction()]).isOK();
}

- (BOOL)loadProperties:(NSError **)error {
    Status status = SQLITE_OK;
    
    while ((status = _fetchProperties->next()).isRow()) {
        Value propertyValue = (*_fetchProperties)["value"];
        Value propertyID = (*_fetchProperties)["id"];
        id value = nil;
        
        if (propertyValue.type() == ValueType::Text) {
            value = [NSString stringWithUTF8String:propertyValue.stringValue().c_str()];
        } else if (propertyValue.type() == ValueType::Float) {
            value = [NSNumber numberWithDouble:propertyValue.doubleValue()];
        } else if (propertyValue.type() == ValueType::Integer) {
            value = [NSNumber numberWithDouble:propertyValue.int64Value()];
        } else {
            value = [NSNull null];
        }
        
        if (propertyID.type() == ValueType::Text) {
            [(NSMutableDictionary *)_properties setValue:value forKey:[NSString stringWithUTF8String:propertyID.stringValue().c_str()]];
        }
    }
    
    if (status.isDone()) {
        return true;
    } else {
        *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        return false;
    }
}

- (BOOL)closeDatabase:(NSError **)error {
    _fetchProperties->close();
    _fetchStopPlaceById->close();
    _fetchStopPlacesByName->close();
    _fetchStopPlacesByLocation->close();
    
    Status status = _db->close();
    
    if (status.isOK()) {
        _valid = false;
        return true;
    } else {
        *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        return false;
    }
}

- (FunctionContext)dbkContextTK:(DBKFunctionContext)functionContext {
    FunctionContext context = FunctionContextEmpty;
    
    context.name = functionContext.name;
    context.valuesCount = functionContext.valuesCount;
    context.info = functionContext.info;
    context.deterministic = functionContext.deterministic;
    
    context.execute = functionContext.execute;
    context.step = functionContext.step;
    context.finalize = functionContext.finalize;
    context.destroy = functionContext.destroy;
    
    return context;
}

#pragma mark - Fetching

- (void)fetchStopPlaceWithID:(TKItemID)itemID completion:(TKStopPlaceFetchHandler)completion {
    if (!_fetchStopPlaceById->clearAndReset().isOK()) {
        return completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
    
    if (!_fetchStopPlaceById->bind(TKUToS64(itemID), ":id").isOK()) {
        return completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
    
    Status status = SQLITE_OK;
    if ((status = _fetchStopPlaceById->next()).isRow()) {
        TKStopPlace *stopPlace = [[TKStopPlace alloc] initWithStatement:_fetchStopPlaceById];
        completion(@[stopPlace], nil);
    } else if (status.isDone()) {
        completion(@[], nil);
    } else {
        completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
}

- (void)fetchStopPlacesWithName:(NSString *)name completion:(TKStopPlaceFetchHandler)completion {
    [self fetchStopPlacesWithName:name completion:completion limit:-1];
}

- (void)fetchStopPlacesWithLocation:(CLLocation *)location completion:(TKStopPlaceFetchHandler)completion {
    [self fetchStopPlacesWithLocation:location completion:completion limit:-1];
}

- (void)fetchStopPlacesWithName:(NSString *)name completion:(TKStopPlaceFetchHandler)completion limit:(TKInt)limit {
    if (!_fetchStopPlacesByName->clearAndReset().isOK()) {
        return completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
    
    if (!_fetchStopPlacesByName->bind(std::string(name.UTF8String).append("%"), ":name").isOK()) {
        return completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
    
    if (!_fetchStopPlacesByName->bind(limit, ":limit").isOK()) {
        return completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
    
    Status status = SQLITE_OK;
    NSMutableArray *stopPlaces = [[NSMutableArray alloc] init];
    
    while ((status = _fetchStopPlacesByName->next()).isRow()) {
        TKStopPlace *stopPlace = [[TKStopPlace alloc] initWithStatement:_fetchStopPlacesByName];
        [stopPlaces addObject:stopPlace];
    }
    
    if (status.isDone()) {
        completion(stopPlaces, nil);
    } else {
        completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
}

- (void)fetchStopPlacesWithLocation:(CLLocation *)location completion:(TKStopPlaceFetchHandler)completion limit:(TKInt)limit {
    if (!_fetchStopPlacesByLocation->clearAndReset().isOK()) {
        return completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
    
    if (!_fetchStopPlacesByLocation->bind(location.coordinate.latitude, ":latitude").isOK()) {
        return completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
    
    if (!_fetchStopPlacesByLocation->bind(location.coordinate.longitude, ":longitude").isOK()) {
        return completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
    
    if (!_fetchStopPlacesByLocation->bind(limit, ":limit").isOK()) {
        return completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
    
    Status status = SQLITE_OK;
    NSMutableArray *stopPlaces = [[NSMutableArray alloc] init];
    
    while ((status = _fetchStopPlacesByLocation->next()).isRow()) {
        TKStopPlace *stopPlace = [[TKStopPlace alloc] initWithStatement:_fetchStopPlacesByLocation];
        [stopPlaces addObject:stopPlace];
    }
    
    if (status.isDone()) {
        completion(stopPlaces, nil);
    } else {
        completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
}

- (void)dealloc {
    [self closeDatabase:nil];
    _db->close();
    
    _url = nil;
    _properties = nil;
}

@end
