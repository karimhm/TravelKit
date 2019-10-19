//
//  TKTripCursor.m
//  TravelKit
//
//  Created by Karim on 10/18/19.
//  Copyright © 2019 Karim. All rights reserved.
//

#import "TKCursor_Private.h"
#import "TKTrip_Private.h"
#import "TKStopTime_Private.h"

using namespace tk;

@implementation TKTripCursor {
    Ref<Statement> _fetchStopTime;
}

- (BOOL)prepareWithQuery:(TKQuery *)query error:(NSError **)error {
    BOOL hasId = false;
    BOOL hasRouteId = false;
    BOOL hasLimit = false;
    
    std::string queryString = ""
    "SELECT id, routeId, direction FROM Trip ";
    
    /* Query Where */
    BOOL hasWhere = false;
    std::string queryWhere = "WHERE ";
    
    if (query.idSet) {
        queryWhere.append(hasWhere ? "AND id = :id ":"id = :id ");
        hasId = true;
        hasWhere = true;
    }
    
    if (query.routeIDSet) {
        queryWhere.append(hasWhere ? "AND routeId = :routeId ":"routeId = :routeId ");
        hasRouteId = true;
        hasWhere = true;
    }
    
    if (hasWhere) {
        queryString.append(queryWhere);
    }
    
    queryString.append("GROUP BY routeId ");
    
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
    
    /* Binding */
    if (hasId && !self.statement->bind(TKUToS64(query.itemID), ":id").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasRouteId && !self.statement->bind(TKUToS64(query.routeID), ":routeId").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasLimit && !self.statement->bind(query.limit, ":limit").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    _fetchStopTime = makeRef<Statement>(self.database, ""
    "SELECT "
        "StopTime.* "
    "FROM StopTime "
        "WHERE tripId = :tripId "
    "ORDER BY position ASC");
    
    if (!_fetchStopTime->prepare().isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    return true;
}

- (nullable TKStopPlace *)fetchStopPlacesWithID:(TKItemID)stopPlacesID {
    TKQuery *query = [[TKQuery alloc] init];
    query.language = self.query.language;
    query.itemID = stopPlacesID;
    
    return [[TKStopPlaceCursor cursorWithDatabase:self.database query:query] fetchOne];
}

- (nullable NSArray <TKStopTime *> *)fetchStopTimesWithTripID:(TKItemID)tripID {
    if (!_fetchStopTime->reset().isOK()) {
        return nil;
    }
    
    if (!_fetchStopTime->bind((int64_t)tripID, ":tripId").isOK()) {
        return nil;
    }
    
    Status status = Status();
    NSMutableArray <TKStopTime *> *stopTimes = [[NSMutableArray alloc] init];
    
    while ((status = _fetchStopTime->next()).isRow()) {
        TKStopTime *stopTime = [[TKStopTime alloc] initWithStatement:_fetchStopTime];
        stopTime.stopPlace = [self fetchStopPlacesWithID:TKSToU64((*_fetchStopTime)["stopPlaceId"].int64Value())];
        
        if (stopTime) {
            [stopTimes addObject:stopTime];
        }
    }
    
    return stopTimes;
}

- (nullable TKTrip *)createObjectWithStatement:(Ref<Statement>)statement {
    TKTrip *trip = [[TKTrip alloc] initWithStatement:statement];
    
    TKQuery *query = [[TKQuery alloc] init];
    query.language = self.query.language;
    query.itemID = TKSToU64((*statement)["routeId"].int64Value());
    
    TKRoute *route = [[TKRouteCursor cursorWithDatabase:self.database query:query] fetchOne];
    if (route) {
        trip.route = route;
    } else {
        return nil;
    }
    
    if (self.query.fetchStopTimes) {
        trip.stopTimes = [self fetchStopTimesWithTripID:trip.identifier];
    }
    
    return trip;
}

@end
