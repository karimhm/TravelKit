/*
 *  CSARouter.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_CSA_ROUTER_H
#define TK_CSA_ROUTER_H

#include "BaseRouter.h"
#include "Connection.h"
#include "Calendar.h"
#include "Trip.h"

namespace tk {

/*
 * Implements the Connection Scan Algorithm algorithm
 */
class CSARouter final : public RefCounted<CSARouter>, public BaseRouter {
public:
    CSARouter(Ref<Database> db) : BaseRouter(db) {
    }
    
    ErrorOr<void> load();
    ErrorOr<void> unload();
    
    bool isLoaded() const {
        return loaded_;
    }
    
    ErrorOr<TripPlan> query(ItemID source, ItemID destination, Date date);
    
private:
    bool loaded_;
    ConnectionVector connections_;
    std::map<ItemID, Calendar> calendarByID_;
    std::map<ItemID, Trip> tripsByID_;
};

}

#endif /* TK_CSA_ROUTER_H */
