/*
 *  BaseRouter.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_ROUTER_H
#define TK_ROUTER_H

#include "Database.h"
#include "ItemID.h"
#include "Date.h"
#include "TripPlan.h"
#include "ErrorOr.h"

namespace tk {
namespace Router {

class Base  {
public:
    Base(Ref<Database> db) : db_(db) {
    }
    
    virtual ErrorOr<TripPlan> query(ItemID source, ItemID destination, Date date) = 0;
    
protected:
    Ref<Database> db_;
};

}
}
    
#endif /* TK_ROUTER_H */
