/*
 *  TKStopPlaceCursor.m
 *  Created on 19/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKCursor_Private.h"
#import "NSError+TravelKit.h"

using namespace tk;

@implementation TKStopPlaceCursor

- (BOOL)prepareWithQuery:(TKQuery *)query error:(NSError **)error {
    BOOL hasId = false;
    BOOL hasName = false;
    BOOL hasLocation = false;
    BOOL hasLimit = false;
    
    std::string queryString = ""
    "SELECT "
        "StopPlace.*, "
        "Localization.text AS name "
    "FROM StopPlace "
    "JOIN "
        "Localization ON Localization.id = StopPlace.nameId "
    "WHERE Localization.language = :language ";
    
    if (query.idSet) {
        queryString.append("AND StopPlace.id = :id ");
        hasId = true;
    }
    
    if (query.name) {
        queryString.append("AND StopPlace.nameId IN (SELECT id FROM Localization WHERE text LIKE :name) ");
        hasName = true;
    }
    
    /* Order By */
    BOOL hasOrderBy = false;
    std::string queryOrder = "ORDER BY ";
    
    if (query.location) {
        queryOrder.append("tkDistance(:latitude, :longitude, latitude, longitude)");
        hasLocation = true;
        hasOrderBy = true;
    }
    
    if (query.orderBy == TKOrderByName) {
        queryOrder.append(hasOrderBy ? ", name":"name");
        hasOrderBy = true;
    }
    
    if (hasOrderBy) {
        if (query.sortOrder == TKSortOrderASC) {
            queryOrder.append(" ASC ");
        } else if (query.sortOrder == TKSortOrderDESC) {
            queryOrder.append(" DESC ");
        }
        
        queryString.append(queryOrder);
    }
    
    /* Limit */
    if (query.limit > 0) {
        queryString.append("LIMIT :limit");
        hasLimit = true;
    }
    
    /* Prepare */
    self.statement = makeRef<Statement>(self.database, queryString);
    if (!self.statement->prepare().isOK()) {
        TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
        return false;
    }
    
    /* Binding */
    if (!self.statement->bind(query.language.UTF8String, ":language").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasId && !self.statement->bind(TKUToS64(query.itemID), ":id").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasName && !self.statement->bind(std::string(query.name.UTF8String).append("%"), ":name").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasLocation && !self.statement->bind(query.location.coordinate.latitude, ":latitude").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasLocation && !self.statement->bind(query.location.coordinate.longitude, ":longitude").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasLimit && !self.statement->bind(query.limit, ":limit").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    return true;
}

- (BOOL)bindWithQuery:(TKQuery *)query error:(NSError **)error {
    return false;
}

- (nullable TKStopPlace *)createObjectWithStatement:(Ref<Statement>)statement {
    TKStopPlace *stopPlace = [[TKStopPlace alloc] initWithStatement:statement];
    return stopPlace;
}

@end
