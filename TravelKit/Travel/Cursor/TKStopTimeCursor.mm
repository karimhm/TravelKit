/*
 *  TKStopTimeCursor.m
 *  Created on 31/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKCursor_Private.h"
#import "TKStopTime_Private.h"

using namespace tk;

@implementation TKStopTimeCursor

- (BOOL)prepareWithQuery:(TKQuery *)query error:(NSError **)error {
    BOOL hasStopPlaceId = false;
    BOOL hasRouteId = false;
    BOOL hasDirection = false;
    BOOL hasLimit = false;
    
    std::string queryString = ""
    "SELECT "
        "StopTime.id, "
        "StopTime.arrivalTime, "
        "StopTime.stopPlaceId, "
        "Trip.calendarId "
    "FROM StopTime "
    "JOIN "
        "Trip on Trip.id = StopTime.tripId ";
    
    /* Query Where */
    BOOL hasWhere = false;
    std::string queryWhere = "WHERE ";
    
    if (query.stopPlaceIDSet) {
        queryWhere.append(hasWhere ? "AND StopTime.stopPlaceId = :stopPlaceId ":"StopTime.stopPlaceId = :stopPlaceId ");
        hasStopPlaceId = true;
        hasWhere = true;
    }
    
    if (query.routeIDSet) {
        queryWhere.append(hasWhere ? "AND Trip.routeId = :routeId ":"Trip.routeId = :routeId ");
        hasRouteId = true;
        hasWhere = true;
    }
    
    if (query.direction != TKTravelDirectionUnknown) {
        queryWhere.append(hasWhere ? "AND Trip.direction = :direction ":"Trip.direction = :direction ");
        hasDirection = true;
        hasWhere = true;
    }
    
    if (hasWhere) {
        queryString.append(queryWhere);
    }
    
    queryString.append("ORDER BY StopTime.arrivalTime ");
    
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
    if (hasStopPlaceId && !self.statement->bind(TKUToS64(query.stopPlaceID), ":stopPlaceId").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasRouteId && !self.statement->bind(TKUToS64(query.routeID), ":routeId").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasDirection && !self.statement->bind((int64_t)query.direction, ":direction").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasLimit && !self.statement->bind(query.limit, ":limit").isOK()) {
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

- (nullable TKCalendar *)fetchCalendarWithID:(TKItemID)calendarID {
    TKQuery *query = [[TKQuery alloc] init];
    query.language = self.query.language;
    query.itemID = calendarID;
    
    return [[TKCalendarCursor cursorWithDatabase:self.database query:query] fetchOne];
}

- (nullable TKStopTime *)createObjectWithStatement:(Ref<Statement>)statement {
    TKStopTime *stopTime = [[TKStopTime alloc] initWithStatement:statement];
    stopTime.stopPlace = [self fetchStopPlacesWithID:TKSToU64((*statement)["stopPlaceId"].int64Value())];
    stopTime.calendar = [self fetchCalendarWithID:TKSToU64((*statement)["calendarId"].int64Value())];
    
    return stopTime;
}

@end
