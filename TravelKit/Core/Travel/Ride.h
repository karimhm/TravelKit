/*
 *  Ride.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_RIDE_H
#define TK_RIDE_H

#include "Ref.h"
#include "ItemID.h"
#include "Stop.h"
#include "Time.h"

namespace tk {

class Ride {
public:
    Ride() {
    }
    
    Ride(StopVector stops, ItemID routeID) : stops_(stops), routeID_(routeID) {
    }
    
    const StopVector stops() const {
        return stops_;
    }
    
    const ItemID routeID() const {
        return routeID_;
    }
    
    const Time duration() const {
        return arrivalTime() - departureTime();
    }
    
    const Time departureTime() const {
        return stops_.front().time();
    }
    
    const Time arrivalTime() const {
        return stops_.back().time();
    }
    
private:
    StopVector stops_;
    ItemID routeID_;
};

using RideVector = std::vector<Ride>;
    
}

#endif /* TK_RIDE_H */
