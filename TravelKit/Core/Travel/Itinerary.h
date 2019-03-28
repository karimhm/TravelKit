/*
 *  Itinerary.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_ITINERARY_H
#define TK_ITINERARY_H

#include "Defines.h"
#include "StopPlace.h"
#include "Ride.h"
#include <vector>

namespace tk {

class Itinerary {
public:
    Itinerary(RideVector rides) : rides_(rides) {
    }
    
    const RideVector rides() const {
        return rides_;
    }
    
    const Time duration() const {
        return rides_.back().arrivalTime() - rides_.front().departureTime();
    }
    
    const Time departureTime() const {
        return rides_.front().departureTime();
    }
    
    const Time arrivalTime() const {
        return rides_.back().arrivalTime();
    }
    
private:
    RideVector rides_;
};

using ItineraryVector = std::vector<Itinerary>;

}

#endif /* TK_ITINERARY_H */
