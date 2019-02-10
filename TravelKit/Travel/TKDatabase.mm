/*
 *  TKDatabase.mm
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKDatabase.h"
#import "NSError+TravelKit.h"
#import "DistanceFunction.h"
#import "TKItem_Core.h"
#import "TKStop_Private.h"
#import "TKItinerary_Private.h"
#import "TKRide_Private.h"
#import "TKTripPlan_Private.h"
#import "TKError.h"
#import "Database.h"
#import "Statement.h"
#import "CSARouter.h"
#import "Itinerary.h"

using namespace tk;

@implementation TKDatabase {
    Ref<Database> _db;
    Ref<Router::CSA> _router;
    Ref<Statement> _fetchProperties;
    Ref<Statement> _fetchLanguages;
    Ref<Statement> _fetchStopPlaceById;
    Ref<Statement> _fetchStopPlacesByName;
    Ref<Statement> _fetchStopPlacesByLocation;
    Ref<Statement> _fetchRouteColorById;
    Ref<Statement> _fetchRouteById;
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
        _languages = [[NSMutableArray alloc] init];
        _db = makeRef<Database>([url fileSystemRepresentation]);
        _router = makeRef<Router::CSA>(_db);
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
        
        if (![self loadLanguages:error]) {
            return false;
        }
        
        if (![self load:error]) {
            return false;
        }
    } else if (error) {
        *error = [NSError tk_badDatabaseError];
    }
    
    _valid = status;
    return status;
}

- (BOOL)prepareStatements:(NSError **)error {
    BOOL status = true;
    
    _fetchProperties = makeRef<Statement>(_db, "SELECT * FROM Properties");
    _fetchLanguages = makeRef<Statement>(_db, "SELECT DISTINCT language from Localization");
    _fetchStopPlaceById = makeRef<Statement>(_db, ""
    "SELECT "
        "StopPlace.*, "
        "Localization.text AS name "
    "FROM StopPlace "
    "JOIN "
        "Localization ON Localization.id = StopPlace.nameId "
    "WHERE StopPlace.id = :id "
    "AND Localization.language = :language");
    
    _fetchStopPlacesByName = makeRef<Statement>(_db, ""
    "SELECT "
        "StopPlace.*, "
        "Localization.text AS name "
    "FROM StopPlace "
    "JOIN "
        "Localization ON Localization.id = StopPlace.nameId "
    "WHERE StopPlace.nameId IN ("
        "SELECT id FROM Localization WHERE text LIKE :name"
    ") "
    "AND Localization.language = :language "
    "LIMIT :limit");
    
    _fetchStopPlacesByLocation = makeRef<Statement>(_db, ""
    "SELECT "
        "StopPlace.*, "
        "Localization.text AS name "
    "FROM StopPlace "
    "JOIN "
        "Localization ON Localization.id = StopPlace.nameId "
    "WHERE Localization.language = :language "
    "GROUP BY "
        "tkDistance(:latitude, :longitude, latitude, longitude) "
    "LIMIT :limit");
    
    _fetchRouteColorById = makeRef<Statement>(_db, "SELECT color FROM Route WHERE id = :id");
    
    _fetchRouteById = makeRef<Statement>(_db, ""
    "SELECT "
        "Route.*, "
        "Localization.text AS name "
    "FROM Route "
    "JOIN "
    "Localization ON Localization.id = Route.nameId "
        "WHERE Route.id = :id "
    "AND Localization.language = :language");
    
    if (!_fetchProperties->prepare().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        status = false;
        goto cleanup;
    }
    
    if (!_fetchLanguages->prepare().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        status = false;
        goto cleanup;
    }
    
    if (!_fetchStopPlaceById->prepare().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        status = false;
        goto cleanup;
    }
    
    if (!_fetchStopPlacesByName->prepare().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        status = false;
        goto cleanup;
    }
    
    if (!_fetchStopPlacesByLocation->prepare().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        status = false;
        goto cleanup;
    }
    
    if (!_fetchRouteColorById->prepare().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        status = false;
        goto cleanup;
    }
    
    if (!_fetchRouteById->prepare().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        status = false;
        goto cleanup;
    }
    
cleanup:
    return status;
}

- (BOOL)addFunctions:(NSError **)error {
    return _db->addFunction(GetDistanceFunction()).isOK();
}

- (BOOL)loadProperties:(NSError **)error {
    Status status = SQLITE_OK;
    
    while ((status = _fetchProperties->next()).isRow()) {
        Value propertyID = (*_fetchProperties)["id"];
        Value propertyValue = (*_fetchProperties)["value"];
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
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return false;
    }
}
    
- (BOOL)loadLanguages:(NSError **)error {
    Status status = Status();
    
    while ((status = _fetchLanguages->next()).isRow()) {
        Value languageValue = (*_fetchLanguages)["language"];
        NSString *language = [NSString stringWithUTF8String:languageValue.stringValue().c_str()];
        
        [(NSMutableArray *)_languages addObject:language];
    }
    
    if (status.isDone()) {
        NSArray<NSString *> *preferred = [NSBundle preferredLocalizationsFromArray:_languages];
        if (preferred.count > 0) {
            _selectedLanguage = preferred.firstObject;
        } else if (_languages.count > 0 && [_properties[@"main_language"] isKindOfClass:[NSString class]]) {
            _selectedLanguage = _properties[@"main_language"];
        } else {
            if (error) {
                *error = [NSError tk_badDatabaseError];
            }
            return false;
        }
        
        return true;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return false;
    }
}

- (BOOL)closeDatabase:(NSError **)error {
    _fetchProperties->close();
    _fetchLanguages->close();
    _fetchStopPlaceById->close();
    _fetchStopPlacesByName->close();
    _fetchStopPlacesByLocation->close();
    _fetchRouteColorById->close();
    _fetchRouteById->close();
    
    _router->unload();
    
    Status status = _db->close();
    
    if (status.isOK()) {
        _valid = false;
        return true;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return false;
    }
}

- (BOOL)load:(NSError **)error {
    auto status = _router->load();
    
    if (status.hasError()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithCode:status.error().code() message:[NSString stringWithUTF8String:status.error().message().c_str()]];
        }
        return false;
    } else {
        return true;
    }
}

#pragma mark - Fetching

- (TKStopPlace *)_fetchStopPlaceWithID:(TKItemID)itemID error:(NSError **)error {
    if (!_fetchStopPlaceById->clearAndReset().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
    
    if (!_fetchStopPlaceById->bind(TKUToS64(itemID), ":id").isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
    
    
    if (!_fetchStopPlaceById->bind(_selectedLanguage.UTF8String, ":language").isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
    
    Status status = SQLITE_OK;
    if ((status = _fetchStopPlaceById->next()).isRow()) {
        TKStopPlace *stopPlace = [[TKStopPlace alloc] initWithStatement:_fetchStopPlaceById];
        return stopPlace;
    } else if (status.isDone()) {
        return nil;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
}

- (UIColor *)_fetchRouteColorWithID:(TKItemID)itemID error:(NSError **)error {
    if (!_fetchRouteColorById->clearAndReset().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
    
    if (!_fetchRouteColorById->bind(TKUToS64(itemID), ":id").isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
    
    Status status = Status();
    if ((status = _fetchRouteColorById->next()).isRow()) {
        Value color = (*_fetchRouteColorById)["color"];
        if (color.isInteger()) {
            return TKColorFromHexRGB(color.intValue());
        } else {
            return nil;
        }
    } else if (status.isDone()) {
        return nil;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
}

- (TKRoute *)_fetchRouteWithID:(TKItemID)itemID error:(NSError **)error {
    if (!_fetchRouteById->clearAndReset().isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
    
    if (!_fetchRouteById->bind(TKUToS64(itemID), ":id").isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
    
    if (!_fetchRouteById->bind(_selectedLanguage.UTF8String, ":language").isOK()) {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
    
    Status status = Status();
    if ((status = _fetchRouteById->next()).isRow()) {
        TKRoute *route = [[TKRoute alloc] initWithStatement:_fetchRouteById];
        return route;
    } else if (status.isDone()) {
        return nil;
    } else {
        if (error) {
            *error = [NSError tk_sqliteErrorWithDB:_db->handle()];
        }
        return nil;
    }
}

- (void)fetchStopPlaceWithID:(TKItemID)itemID completion:(TKStopPlaceFetchHandler)completion {
    NSError *error = nil;
    TKStopPlace *stopPlace = [self _fetchStopPlaceWithID:itemID error:&error];
    
    if (completion) {
        if (stopPlace) {
            completion(@[stopPlace], error);
        } else {
            completion(@[], error);
        }
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
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
        return;
    }
    
    if (!_fetchStopPlacesByName->bind(std::string(name.UTF8String).append("%"), ":name").isOK()) {
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
        return;
    }
    
    if (!_fetchStopPlacesByName->bind(_selectedLanguage.UTF8String, ":language").isOK()) {
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
        return;
    }
    
    if (!_fetchStopPlacesByName->bind(limit, ":limit").isOK()) {
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
        return;
    }
    
    Status status = SQLITE_OK;
    NSMutableArray *stopPlaces = [[NSMutableArray alloc] init];
    
    while ((status = _fetchStopPlacesByName->next()).isRow()) {
        TKStopPlace *stopPlace = [[TKStopPlace alloc] initWithStatement:_fetchStopPlacesByName];
        [stopPlaces addObject:stopPlace];
    }
    
    if (status.isDone()) {
        if (completion) {
            completion(stopPlaces, nil);
        }
    } else {
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
    }
}

- (void)fetchStopPlacesWithLocation:(CLLocation *)location completion:(TKStopPlaceFetchHandler)completion limit:(TKInt)limit {
    if (!_fetchStopPlacesByLocation->clearAndReset().isOK()) {
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
        return;
    }
    
    if (!_fetchStopPlacesByLocation->bind(location.coordinate.latitude, ":latitude").isOK()) {
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
        return;
    }
    
    if (!_fetchStopPlacesByLocation->bind(location.coordinate.longitude, ":longitude").isOK()) {
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
        return;
    }
    
    if (!_fetchStopPlacesByLocation->bind(_selectedLanguage.UTF8String, ":language").isOK()) {
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
        return;
    }
    
    if (!_fetchStopPlacesByLocation->bind(limit, ":limit").isOK()) {
        if (completion) {
            completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        }
        return;
    }
    
    Status status = Status();
    NSMutableArray *stopPlaces = [[NSMutableArray alloc] init];
    
    while ((status = _fetchStopPlacesByLocation->next()).isRow()) {
        TKStopPlace *stopPlace = [[TKStopPlace alloc] initWithStatement:_fetchStopPlacesByLocation];
        [stopPlaces addObject:stopPlace];
    }
    
    if (status.isDone()) {
        if (completion) {
            completion(stopPlaces, nil);
        }
    } else if (completion) {
        completion(nil, [NSError tk_sqliteErrorWithDB:_db->handle()]);
    }
}

- (void)fetchTripPlanWithRequest:(TKTripPlanRequest *)request completion:(TKTripPlanFetchHandler)completion {
    [self fetchTripPlanWithRequest:request completion:completion limit:-1];
}

- (void)fetchTripPlanWithRequest:(TKTripPlanRequest *)request completion:(TKTripPlanFetchHandler)completion limit:(TKInt)limit {
    ItemID from = request.source.identifier;
    ItemID to = request.destination.identifier;
    uint64_t departure = request.date.timeIntervalSince1970;
    uint64_t dayBegin = departure - (departure % 86400);
    
    auto tripPlan = _router->query(from, to, departure);
    
    if (tripPlan.hasValue()) {
        NSMutableArray *itineraries = [[NSMutableArray alloc] init];
        
        for (auto const &itinerary: tripPlan.value().itineraries()) {
            NSMutableArray<TKRide *> *rides = [[NSMutableArray alloc] init];
            TKStopPlace *source = nil;
            TKStopPlace *destination = nil;
            NSDate *departureDate = nil;
            NSDate *arrivalDate = nil;
            
            /* Add rides */
            for (auto const &ride: itinerary->rides()) {
                NSMutableArray<TKStop *> *stops = [[NSMutableArray alloc] init];
                
                /* Add stops */
                for (auto const &stop: ride.stops()) {
                    TKStopPlace *stopPlace = [self _fetchStopPlaceWithID:stop.stopPlaceID() error:nil];
                    [stops addObject:[[TKStop alloc] initWithStopPlace:stopPlace
                                                                  date:[NSDate dateWithTimeIntervalSince1970:dayBegin + stop.time()]]];
                }
                
                TKRoute *route = [self _fetchRouteWithID:ride.routeID() error:nil];
                [rides addObject:[[TKRide alloc] initWithStops:stops route:route]];
            }
            
            departureDate = rides.firstObject.stops.firstObject.date;
            arrivalDate = rides.lastObject.stops.lastObject.date;
            source = rides.firstObject.stops.firstObject.stopPlace;
            destination = rides.lastObject.stops.lastObject.stopPlace;
            
            [itineraries addObject:[[TKItinerary alloc] initWithRides:rides
                                                        departureDate:departureDate
                                                          arrivalDate:arrivalDate
                                                               source:source
                                                          destination:destination]];
        }
        
        if (completion) {
            TKTripPlan *tripPlan = [[TKTripPlan alloc] initWithSource:request.source destination:request.destination date:request.date itineraries:itineraries];
            completion(tripPlan, nil);
        }
    } else {
        if (completion) {
            Error error = tripPlan.error();
            completion(nil, [NSError tk_sqliteErrorWithCode:error.code() message:[NSString stringWithUTF8String:error.message().c_str()]]);
        }
    }
}

- (void)dealloc {
    _url = nil;
    _properties = nil;
    _languages = nil;
}

@end
