/*
 *  TKDatabase.mm
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKDatabase.h"
#import "TKDefines_Private.h"
#import "TKConstants_Private.h"
#import "NSError+TravelKit.h"
#import "DistanceFunction.h"
#import "TKItem_Core.h"
#import "TKCursor_Private.h"
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

struct _TKDatabaseFeatureFlags {
    BOOL routePattern;
};

@implementation TKDatabase {
    Ref<Database> _db;
    Ref<Router::CSA> _router;
    Ref<Statement> _fetchProperties;
    Ref<Statement> _fetchLanguages;
    
    _TKDatabaseFeatureFlags _features;
    
    NSString *_name;
    NSUUID *_uuid;
    NSDate *_timestamp;
    NSTimeZone *_timeZone;
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
    if (_db->isOpen()) {
        if (error) {
            *error = nil;
        }
        
        return true;
    }
    
    BOOL status = _db->open(Database::Options::OpenReadOnly).isOK();
    
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
        
        [self checkFeatures];
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
    
cleanup:
    return status;
}

- (BOOL)addFunctions:(NSError **)error {
    return _db->addFunction(GetDistanceFunction()).isOK();
}

- (void)checkFeatures {
    _features.routePattern = _db->tableExist("RoutePattern");
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
        if ([_properties[@"name"] isKindOfClass:[NSString class]]) {
            _name = _properties[@"name"];
        }
        
        if ([_properties[@"uuid"] isKindOfClass:[NSString class]]) {
            _uuid = [[NSUUID alloc] initWithUUIDString:_properties[@"uuid"]];
        }
        
        if ([_properties[@"timestamp"] isKindOfClass:[NSNumber class]]) {
            _timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:[_properties[@"timestamp"] doubleValue]];
        }
        
        if ([_properties[@"timezone"] isKindOfClass:[NSString class]]) {
            _timeZone = [[NSTimeZone alloc] initWithName:_properties[@"timezone"]];
        }
        
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
    if (_fetchProperties) {
        _fetchProperties->close();
    }
    
    if (_fetchLanguages) {
        _fetchLanguages->close();
    }
    
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

#pragma mark - Properties

- (BOOL)supportFeature:(TKDatabaseFeature)feature {
    switch (feature) {
        case TKDatabaseFeatureRoutePattern:
            return _features.routePattern;
            
        default:
            return false;
    }
}

- (NSUUID *)uuid {
    return _uuid;
}

- (NSDate *)timestamp {
    return _timestamp;
}

- (NSTimeZone *)timeZone {
    return _timeZone;
}

#pragma mark - Fetching (Private)

- (TKStopPlace *)_fetchStopPlaceWithID:(TKItemID)itemID error:(NSError **)error {
    TKQuery *query = [[TKQuery alloc] init];
    query.itemID = itemID;
    
    return [[self fetchStopPlaceWithQuery:query error:error] fetchOneWithError:error];
}

- (TKRoute *)_fetchRouteWithID:(TKItemID)itemID error:(NSError **)error {
    TKQuery *query = [[TKQuery alloc] init];
    query.itemID = itemID;
    
    return [[self fetchRouteWithQuery:query error:error] fetchOneWithError:error];
}

- (TKCalendar *)_fetchCalendarWithID:(TKItemID)itemID error:(NSError **)error {
    TKQuery *query = [[TKQuery alloc] init];
    query.itemID = itemID;
    
    return [[self fetchCalendarWithQuery:query error:error] fetchOneWithError:error];
}

#pragma mark - Fetching

- (TKCursor <TKStopPlace *> *)fetchStopPlaceWithQuery:(TKQuery *)query {
    return [self fetchStopPlaceWithQuery:query error:nil];
}

- (TKCursor <TKRoute *> *)fetchRouteWithQuery:(TKQuery *)query {
    return [self fetchRouteWithQuery:query error:nil];
}

- (TKCursor <TKCalendar *> *)fetchCalendarWithQuery:(TKQuery *)query {
    return [self fetchCalendarWithQuery:query error:nil];
}

- (TKCursor <TKRoutePattern *> *)fetchRoutePatternWithQuery:(TKQuery *)query {
    return [self fetchRoutePatternWithQuery:query error:nil];
}

- (TKCursor <TKStopTime *> *)fetchStopTimeWithQuery:(TKQuery *)query {
    return [self fetchStopTimeWithQuery:query error:nil];
}

- (TKCursor <TKTrip *> *)fetchTripWithQuery:(TKQuery *)query {
    return [self fetchTripWithQuery:query error:nil];
}

- (TKCursor <TKStopPlace *> *)fetchStopPlaceWithQuery:(TKQuery *)query error:(NSError **)error {
    query.language = _selectedLanguage;
    return [TKStopPlaceCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKRoute *> *)fetchRouteWithQuery:(TKQuery *)query error:(NSError **)error {
    query.language = _selectedLanguage;
    return [TKRouteCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKCalendar *> *)fetchCalendarWithQuery:(TKQuery *)query error:(NSError **)error {
    query.language = _selectedLanguage;
    return [TKCalendarCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKRoutePattern *> *)fetchRoutePatternWithQuery:(TKQuery *)query error:(NSError **)error {
    query.language = _selectedLanguage;
    return [TKRoutePatternCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKStopTime *> *)fetchStopTimeWithQuery:(TKQuery *)query error:(NSError **)error {
    query.language = _selectedLanguage;
    return [TKStopTimeCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKTrip *> *)fetchTripWithQuery:(TKQuery *)query error:(NSError **)error {
    query.language = _selectedLanguage;
    query.fetchStopTimes = true;
    return [TKTripCursor cursorWithDatabase:_db query:query error:error];
}

- (void)fetchTripPlanWithRequest:(TKTripPlanRequest *)request completion:(TKTripPlanFetchHandler)completion {
    ItemID from = request.source.identifier;
    ItemID to = request.destination.identifier;
    time_t departure = request.date.timeIntervalSince1970;
    NSDate *dayBegining = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601] startOfDayForDate:request.date];
    NSInteger seconds = [_timeZone secondsFromGMTForDate:dayBegining];
    
    auto options = tk::Router::QueryOptions();
    options.omitSameTripArrival(request.options & TKTripPlanOptionsOmitSameTripArrival);
    
    const auto tripPlan = _router->query(from, to, Date(departure), options);
    
    if (tripPlan.hasValue()) {
        NSMutableArray <TKItinerary *> *itineraries = [[NSMutableArray alloc] init];
        
        for (auto const &itinerary: tripPlan.value().itineraries()) {
            NSMutableArray<TKRide *> *rides = [[NSMutableArray alloc] init];
            TKStopPlace *source = nil;
            TKStopPlace *destination = nil;
            NSDate *departureDate = nil;
            NSDate *arrivalDate = nil;
            
            /* Add rides */
            for (auto const &ride: itinerary.rides()) {
                NSMutableArray<TKStop *> *stops = [[NSMutableArray alloc] init];
                
                /* Add stops */
                for (auto const &stop: ride.stops()) {
                    TKStopPlace *stopPlace = [self _fetchStopPlaceWithID:stop.stopPlaceID() error:nil];
                    NSDate *date = [NSDate dateWithTimeInterval:stop.time().seconds() + seconds sinceDate:dayBegining];
                    [stops addObject:[[TKStop alloc] initWithStopPlace:stopPlace date:date]];
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
    _name = nil;
    _languages = nil;
    _timeZone = nil;
}

@end
