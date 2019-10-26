//
//  RAPTORRouter.cpp
//  TravelKit
//
//  Created by Karim on 8/3/19.
//  Copyright © 2019 Karim. All rights reserved.
//

#include "RAPTORRouter.h"
#include "Mapping.h"
#include "Error.h"

using namespace tk;
using namespace tk::Router;

ErrorOr<void> RAPTOR::load() {
    if (loaded_) {
        return {};
    }
    
    Status status = {};
    std::map<ItemID, Calendar> calendarByID = {};
    
    Ref<Statement> fetchStmt;
    
    fetchStmt = makeRef<Statement>(db_, "SELECT id, days FROM Calendar");
    if (fetchStmt->prepare().isOK()) {
        CalendarMapping mapping = CalendarMapping(fetchStmt);
        
        while (fetchStmt->next().isRow()) {
            ItemID id = (*fetchStmt)[mapping.idIndex()].int64Value();
            uint8_t days = (*fetchStmt)[mapping.daysIndex()].int64Value();
            
            calendarByID[id] = Calendar(id, days);
        }
        
        if (!status.isDone()) {
            return Error(db_->handle());
        }
    }
    
    fetchStmt->close();
    
    calendarByID_ = std::move(calendarByID);
    loaded_ = true;
    
    return {};
}

ErrorOr<void> RAPTOR::unload() {
    loaded_ = false;
    
    return {};
}

ErrorOr<TripPlan> RAPTOR::query(ItemID source, ItemID destination, Date date, QueryOptions options) {
    std::map<ItemID, Calendar> calendars;
    
    // Fetch all the available Calendars for the given date
    // So connections that are not available at the given date will not be considered
    for (const auto &calendar: calendarByID_) {
        if (calendar.second.isAvailable(date)) {
            calendars[calendar.second.id()] = calendar.second;
        }
    }
    
    std::terminate();
}
