/*
 *  TKRouteLineCursor.mm
 *  Created on 5/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKCursor_Private.h"
#import "TKRouteLine_Private.h"

using namespace tk;

typedef NS_OPTIONS(NSInteger, TKTravelDirection) {
    TKTravelDirectionUnknown         = 0,
    TKTravelDirectionOutbound        = 1,
    TKTravelDirectionInbound         = 2
};

@implementation TKRouteLineCursor {
    Ref<Statement> _fetchStopPlaceID;
}

- (BOOL)prepareWithQuery:(TKQuery *)query error:(NSError **)error {
    BOOL hasRouteId = false;
    BOOL hasLimit = false;
    
    std::string queryString = ""
    "SELECT routeId, direction FROM RouteLine ";
    
    /* Query Where */
    BOOL hasWhere = false;
    std::string queryWhere = "WHERE ";
    
    if (query.routeIDSet) {
        queryWhere.append(hasWhere ? "AND routeId = :routeId ":"routeId = :routeId ");
        hasRouteId = true;
        hasWhere = true;
    }
    
    if (hasWhere) {
        queryString.append(queryWhere);
    }
    
    queryString.append("GROUP BY routeId");
    
    /* Limit */
    if (query.limit > 0) {
        queryString.append("LIMIT :limit");
        hasLimit = true;
    }
    
    /* Prepare */
    self.statement = makeRef<Statement>(self.database, queryString);
    if (!self.statement->prepare().isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    _fetchStopPlaceID = makeRef<Statement>(self.database, ""
    "SELECT "
        "StopPlace.*, "
        "Localization.text as name "
    "FROM RouteLine "
        "JOIN StopPlace on StopPlace.id = RouteLine.stopPlaceId "
        "JOIN Localization ON Localization.id = StopPlace.nameId "
    "WHERE routeId = :routeId "
    "AND direction = :direction "
    "AND Localization.language = :language "
    "ORDER BY position ASC");
    
    
    if (!_fetchStopPlaceID->prepare().isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    /* Binding */
    if (hasRouteId && !self.statement->bind((int64_t)query.routeID, ":routeId").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasLimit && !self.statement->bind(query.limit, ":limit").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (!_fetchStopPlaceID->bind(query.language.UTF8String, ":language").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    return true;
}

- (nullable NSArray <TKStopPlace *> *)fetchStopPlacesWithRouteID:(TKItemID)routeID direction:(TKTravelDirection)direction {
    if (!_fetchStopPlaceID->reset().isOK()) {
        return nil;
    }
    
    if (!_fetchStopPlaceID->bind((int64_t)routeID, ":routeId").isOK()) {
        return nil;
    }
    
    if (!_fetchStopPlaceID->bind((int64_t)direction, ":direction").isOK()) {
        return nil;
    }
    
    Status status = Status();
    NSMutableArray <TKStopPlace *> *stopPlaces = [[NSMutableArray alloc] init];
    
    while ((status = _fetchStopPlaceID->next()).isRow()) {
        TKStopPlace *stopPlace = [[TKStopPlace alloc] initWithStatement:_fetchStopPlaceID];
        
        if (stopPlace) {
            [stopPlaces addObject:stopPlace];
        }
    }
    
    return stopPlaces;
}

- (nullable TKRouteLine *)createObjectWithStatement:(Ref<Statement>)statement {
    TKRouteLine *routeLine = [[TKRouteLine alloc] initWithStatement:statement];
    
    TKQuery *query = [[TKQuery alloc] init];
    query.language = self.query.language;
    query.itemID = TKSToU64((*statement)["routeId"].int64Value());
    
    TKRoute *route = [[TKRouteCursor cursorWithDatabase:self.database query:query] fetchOne];
    if (route) {
        routeLine.route = route;
    } else {
        return nil;
    }
    
    routeLine.outboundStopPlaces = [self fetchStopPlacesWithRouteID:route.identifier direction:TKTravelDirectionOutbound];
    routeLine.inboundStopPlaces = [self fetchStopPlacesWithRouteID:route.identifier direction:TKTravelDirectionInbound];
    
    return routeLine;
}

- (BOOL)close {
    if ([super close]) {
        if (_fetchStopPlaceID) {
            return _fetchStopPlaceID->close().isOK();
        }
        
        return true;
    } else {
        return false;
    }
}

@end
