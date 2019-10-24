/*
 *  TKRouteCursor.m
 *  Created on 19/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKCursor_Private.h"
#import "NSError+TravelKit.h"

using namespace tk;

@implementation TKRouteCursor

- (BOOL)prepareWithQuery:(TKQuery *)query error:(NSError **)error {
    BOOL hasId = false;
    BOOL hasName = false;
    BOOL hasLimit = false;
    
    std::string queryString = ""
    "WITH PreferedLocalization AS ("
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
        "GROUP BY id "
    ") "
    "SELECT "
        "Route.*, "
        "NameLocalization.text AS name, "
        "DescriptionLocalization.text AS description "
    "FROM Route "
    "JOIN "
        "PreferedLocalization AS NameLocalization ON NameLocalization.id = Route.nameId, "
        "PreferedLocalization AS DescriptionLocalization ON DescriptionLocalization.id = Route.descriptionId ";
    
    if (query.idSet) {
        queryString.append("AND Route.id = :id ");
        hasId = true;
    }
    
    if (query.name) {
        queryString.append("AND Route.nameId IN (SELECT id FROM Localization WHERE text LIKE :name) ");
        hasName = true;
    }
    
    /* Order By */
    BOOL hasOrderBy = false;
    std::string queryOrder = "ORDER BY ";
    
    if (query.orderBy == TKOrderByName) {
        queryOrder.append("name");
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
    if (hasId && !self.statement->bind(TKUToS64(query.itemID), ":id").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasName && !self.statement->bind(std::string(query.name.UTF8String).append("%"), ":name").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    if (hasLimit && !self.statement->bind(query.limit, ":limit").isOK()) {
        return TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
    }
    
    return true;
}

- (nullable TKRoute *)createObjectWithStatement:(Ref<Statement>)statement {
    TKRoute *route = [[TKRoute alloc] initWithStatement:statement];
    return route;
}

@end
