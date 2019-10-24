/*
 *  TKCalendarCursor.m
 *  Created on 20/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKCursor_Private.h"
#import "TKCalendar_Private.h"

using namespace tk;

@implementation TKCalendarCursor {
    NSTimeZone *_timezone;
}

- (BOOL)prepareWithQuery:(TKQuery *)query error:(NSError **)error {
    BOOL hasId = false;
    BOOL hasName = false;
    BOOL hasLimit = false;
    
    std::string queryString = ""
    "SELECT Properties.value FROM Properties WHERE id = 'timezone'";
    
    /* Query timezone */
    Statement fetchTimezone = Statement(self.database, queryString);
    if (!fetchTimezone.prepare().isOK()) {
        TKSetError(error, [NSError tk_sqliteErrorWithDB:self.database->handle()]);
        return false;
    }
    
    if (fetchTimezone.next().isRow()) {
        Value value = fetchTimezone["value"];
        if (value.type() == ValueType::Text) {
            _timezone = [[NSTimeZone alloc] initWithName:[NSString stringWithUTF8String:value.stringValue().c_str()]];
        }
    }
    
    if (!_timezone) {
        TKSetError(error, [NSError tk_internalDatabaseError]);
        return false;
    }
    
    /* Query calendar */
    queryString = ""
    "SELECT "
        "Calendar.*, "
        "NameLocalization.text AS name, "
        "ShortNameLocalization.text AS shortName "
    "FROM Calendar "
    "JOIN "
        "vPreferedLocalization AS NameLocalization ON NameLocalization.id = Calendar.nameId, "
        "vPreferedLocalization AS ShortNameLocalization ON ShortNameLocalization.id = Calendar.shortNameId ";
    
    if (query.idSet) {
        queryString.append("AND Calendar.id = :id ");
        hasId = true;
    }
    
    if (query.name) {
        queryString.append("AND Calendar.nameId IN (SELECT id FROM Localization WHERE text LIKE :name) ");
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

- (nullable TKCalendar *)createObjectWithStatement:(Ref<Statement>)statement {
    TKCalendar *calendar = [[TKCalendar alloc] initWithStatement:statement];
    calendar.timeZone = _timezone;
    return calendar;
}

@end
