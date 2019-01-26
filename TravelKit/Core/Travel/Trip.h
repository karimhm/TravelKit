/*
 *  Trip.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_TRIP_H
#define TK_TRIP_H

#include "Ref.h"
#include "ItemID.h"
#include "StopTime.h"

namespace tk {

using Features = uint64_t;

class Trip {
public:
    Trip() {
    }
    
    Trip(ItemID id, ItemID calendarID, ItemID routeID)
         : id_(id)
         , calendarID_(calendarID)
         , routeID_(routeID)
    {
    }
    
    const ItemID id() const {
        return id_;
    }
    
    const ItemID routeID() const {
        return routeID_;
    }
    
    const ItemID calendarID() const {
        return calendarID_;
    }
    
private:
    ItemID id_;
    ItemID calendarID_;
    ItemID routeID_;
};

using TripVector = std::vector<Trip>;

}

#endif /* TK_TRIP_H */
