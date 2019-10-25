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
#import "TKLogger.h"
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
    
    NSString *_mainLanguage;
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
        _properties = [[NSDictionary alloc] init];
        _languages = [[NSArray alloc] init];
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
        
        TKLogInfo(@"database <%@> opened successfully", self.uuid);
        
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
    Status status = {};
    
    NSMutableDictionary <NSString *, id> *properties = [[NSMutableDictionary alloc] init];
    
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
            [properties setValue:value forKey:[NSString stringWithUTF8String:propertyID.stringValue().c_str()]];
        }
    }
    
    _properties = [properties copy];
    
    if (status.isDone()) {
        if ([properties[@"main_language"] isKindOfClass:[NSString class]]) {
            _mainLanguage = properties[@"main_language"];
        } else {
            TKLogError(@"'main_language' property is missing from <%@> database", _uuid.UUIDString);
            TKSetError(error, [NSError tk_badDatabaseError]);
            return false;
        }
        
        if ([properties[@"timezone"] isKindOfClass:[NSString class]]) {
            _timeZone = [[NSTimeZone alloc] initWithName:properties[@"timezone"]];
        } else {
            TKLogError(@"'timezone' property is missing from <%@> database", _uuid.UUIDString);
            TKSetError(error, [NSError tk_badDatabaseError]);
            return false;
        }
        
        // Optional properties
        
        if ([properties[@"name"] isKindOfClass:[NSString class]]) {
            _name = properties[@"name"];
        }
        
        if ([properties[@"uuid"] isKindOfClass:[NSString class]]) {
            _uuid = [[NSUUID alloc] initWithUUIDString:properties[@"uuid"]];
        }
        
        if ([properties[@"timestamp"] isKindOfClass:[NSNumber class]]) {
            _timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:[properties[@"timestamp"] doubleValue]];
        }
        
        return true;
    } else {
        TKSetError(error, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        return false;
    }
}

- (BOOL)loadLanguages:(NSError **)error {
    Status status = {};
    
    // prefered locale table
    Statement createTableStmt = Statement(_db, ""
    "CREATE TEMP TABLE IF NOT EXISTS tkPreferedLocale ("
        "id TEXT NOT NULL UNIQUE, "
        "priority INTEGER NOT NULL UNIQUE"
    ")");
    
    if (!createTableStmt.prepare().isOK() || !createTableStmt.execute().isDone()) {
        TKSetError(error, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        return false;
    }
    
    // prefered localizations view
    Statement createViewStmt = Statement(_db, ""
    "CREATE TEMP VIEW IF NOT EXISTS vPreferedLocalization AS "
    "SELECT "
        "id, "
        "text "
    "FROM ( "
        "WITH Locales AS (SELECT id, priority FROM tkPreferedLocale) "
        "SELECT "
            "Localization.id, "
            "Localization.text "
        "FROM Localization "
        "JOIN "
            "Locales ON Locales.id = Localization.language "
        "ORDER BY Locales.priority ASC "
    ") "
    "GROUP BY id");
    
    if (!createViewStmt.prepare().isOK() || !createViewStmt.execute().isDone()) {
        TKSetError(error, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        return false;
    }
    
    NSMutableArray <NSString *> *languages = [[NSMutableArray alloc] init];
    
    if (!_fetchLanguages->reset().isOK()) {
        TKSetError(error, [NSError tk_badDatabaseError]);
        return false;
    }
    
    while ((status = _fetchLanguages->next()).isRow()) {
        Value languageValue = (*_fetchLanguages)["language"];
        NSString *language = [NSString stringWithUTF8String:languageValue.stringValue().c_str()];
        
        [languages addObject:language];
    }
    
    // It's and error if the database doesn't contain any language
    if (!languages.count) {
        TKLogError(@"database <%@> doesn't have any languages", _uuid.UUIDString);
        TKSetError(error, [NSError tk_badDatabaseError]);
        return false;
    }
    
    NSMutableArray <NSString *> *preferenceLanguages = [[NSLocale preferredLanguages] mutableCopy];
    
    // Add the main language to the end of the preference languages list
    // so when it's not possible to determine the user prefered languages
    // the main language will be used as fallback
    if (![preferenceLanguages containsObject:_mainLanguage]) {
        [preferenceLanguages addObject:_mainLanguage];
    }
    
    if (status.isDone()) {
        NSMutableArray <NSString *> *preferredLanguages = [[NSMutableArray alloc] init];
        NSMutableArray <NSString *> *candidateLanguages = [[NSMutableArray alloc] initWithArray:languages];
        
        for (NSInteger i = 0; i < languages.count; i++) {
            NSString *language = [NSBundle preferredLocalizationsFromArray:candidateLanguages
                                                            forPreferences:preferenceLanguages].firstObject;
            if (language && ![preferredLanguages containsObject:language]) {
                [preferredLanguages addObject:language];
                [candidateLanguages removeObject:language];
                
                // Once the main language is reached the loop need to be stopped
                // because the remaining languages are not prefered by the user
                // and adding them will slow the queries
                if ([language isEqualToString:_mainLanguage]) {
                    break;
                }
            }
        }
        
        if (![preferredLanguages containsObject:_mainLanguage]) {
            [preferredLanguages addObject:_mainLanguage];
        }
        
        if (![self insertPreferedLanguages:preferredLanguages error:error]) {
            return false;
        }
        
        _languages = [languages copy];
        _selectedLanguages = [preferredLanguages copy];
        
        if (!_selectedLanguages.count) {
            TKLogError(@"Unable to determine the user prefered locales");
            TKSetError(error, [NSError tk_internalDatabaseError]);
            return false;
        }
        
        return true;
    } else {
        TKSetError(error, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        return false;
    }
}

- (BOOL)insertPreferedLanguages:(NSArray <NSString *> *)languages error:(NSError **)error {
    // Delete all locales
    Statement deleteStmt = Statement(_db, "DELETE FROM tkPreferedLocale");
    if (!deleteStmt.prepare().isOK() || !deleteStmt.execute().isDone()) {
        TKLogError(@"Failed to create prefered locales temporary table");
        TKSetError(error, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        return false;
    }
    
    // Insert locales
    Statement insertStmt = Statement(_db, "INSERT INTO tkPreferedLocale(id, priority) VALUES(:id, :priority)");
    if (!insertStmt.prepare().isOK()) {
        TKLogError(@"Failed to prepare statement of insertion to prefered locales temporary table");
        TKSetError(error, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        return false;
    }
    
    for (NSInteger i = 0; i < languages.count; i++) {
        if (!insertStmt.clearAndReset().isOK()
            || !insertStmt.bind(languages[i].UTF8String, ":id").isOK()
            || !insertStmt.bind((int32_t)i, ":priority").isOK())
        {
            TKSetError(error, [NSError tk_sqliteErrorWithDB:_db->handle()]);
            return false;
        }
        
        if (!insertStmt.execute().isDone()) {
            TKSetError(error, [NSError tk_sqliteErrorWithDB:_db->handle()]);
            return false;
        }
    }
    
    return true;
}

- (void)setSelectedLanguages:(NSArray<NSString *> *)selectedLanguages {
    if (selectedLanguages) {
        _selectedLanguages = selectedLanguages;
        [self insertPreferedLanguages:selectedLanguages error:nil];
    } else {
        if (![self loadLanguages:nil]) {
            if (_mainLanguage) {
                NSArray *languages = @[_mainLanguage];
                _selectedLanguages = languages;
                [self insertPreferedLanguages:_selectedLanguages error:nil];
            } else {
                _selectedLanguages = @[];
                [self insertPreferedLanguages:_selectedLanguages error:nil];
            }
        }
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
        TKLogError(@"Failed to close <%@> database", _uuid.UUIDString);
        TKSetError(error, [NSError tk_sqliteErrorWithDB:_db->handle()]);
        return false;
    }
}

- (BOOL)load:(NSError **)error {
    auto status = _router->load();
    
    if (status.hasError()) {
        TKLogError(@"Failed to load trip router. %s", status.error().message().c_str());
        TKSetError(error, [NSError tk_sqliteErrorWithCode:status.error().code() message:[NSString stringWithUTF8String:status.error().message().c_str()]]);
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
    return [TKStopPlaceCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKRoute *> *)fetchRouteWithQuery:(TKQuery *)query error:(NSError **)error {
    return [TKRouteCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKCalendar *> *)fetchCalendarWithQuery:(TKQuery *)query error:(NSError **)error {
    return [TKCalendarCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKRoutePattern *> *)fetchRoutePatternWithQuery:(TKQuery *)query error:(NSError **)error {
    return [TKRoutePatternCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKStopTime *> *)fetchStopTimeWithQuery:(TKQuery *)query error:(NSError **)error {
    return [TKStopTimeCursor cursorWithDatabase:_db query:query error:error];
}

- (TKCursor <TKTrip *> *)fetchTripWithQuery:(TKQuery *)query error:(NSError **)error {
    query.fetchStopTimes = true;
    return [TKTripCursor cursorWithDatabase:_db query:query error:error];
}

- (void)fetchTripPlanWithRequest:(TKTripPlanRequest *)request completion:(TKTripPlanFetchHandler)completion {
    ItemID from = request.source.identifier;
    ItemID to = request.destination.identifier;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601];
    NSDate *dayBegining = [calendar startOfDayForDate:request.date];
    NSDateComponents *dateComponents = [calendar componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:request.date];
    
    auto options = tk::Router::QueryOptions();
    options.omitSameTripArrival(request.options & TKTripPlanOptionsOmitSameTripArrival);
    
    uint32_t seconds = uint32_t((dateComponents.hour * TKSecondsInHour)
                                + (dateComponents.minute * TKSecondsInMinute)
                                + dateComponents.second);
    
    // substract 1 from weekday because the first day of the week in 'NSCalendar' is 1 rather than 0
    auto date = Date(dateComponents.year,
                     dateComponents.month,
                     dateComponents.day,
                     dateComponents.weekday - 1,
                     seconds);
    
    const auto tripPlan = _router->query(from, to, date, options);
    
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
                    NSDate *date = [NSDate dateWithTimeInterval:stop.time().seconds() sinceDate:dayBegining];
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
            TKLogError(@"Failed to fetch trip plan. %s", error.message().c_str());
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
