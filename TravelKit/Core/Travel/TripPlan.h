/*
 *  TripPlan.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_TRIP_PLAN_H
#define TK_TRIP_PLAN_H

#include "Ref.h"
#include "ItemID.h"
#include "Date.h"
#include "Itinerary.h"

namespace tk {

class TripPlan : public RefCounted<TripPlan> {
public:
    TripPlan(ItemID from, ItemID to, Date date, ItineraryVector itineraries)
             : from_(from)
             , to_(to)
             , date_(date)
             , itineraries_(itineraries)
    {
    }
    
    const ItemID from() const {
        return from_;
    }
    
    const ItemID to() const {
        return to_;
    }
    
    const Date date() const {
        return date_;
    }
    
    const ItineraryVector itineraries() const {
        return itineraries_;
    }
    
private:
    ItemID from_;
    ItemID to_;
    Date date_;
    ItineraryVector itineraries_;
};

}

#endif /* TK_TRIP_PLAN_H */
