/*
 *  RAPTORRouter.hpp
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_RAPTOR_ROUTER_H
#define TK_RAPTOR_ROUTER_H

#include "BaseRouter.h"
#include "Calendar.h"

namespace tk {
namespace Router {

/*
 * Implements the Round-Based Public Transit Routing (RAPTOR) algorithm
 */
class RAPTOR final : public RefCounted<RAPTOR>, public Base {
public:
    RAPTOR(Ref<Database> db) : Base(db) {
    }
    
    ErrorOr<void> load();
    ErrorOr<void> unload();
    
    ErrorOr<TripPlan> query(ItemID source, ItemID destination, Date date, QueryOptions options);
private:
    std::map<ItemID, Calendar> calendarByID_;
};

}
}

#endif /* TK_RAPTOR_ROUTER_H */
