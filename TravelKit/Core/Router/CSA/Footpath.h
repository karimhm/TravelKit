/*
 *  Footpath.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_FOOTPATH_H
#define TK_FOOTPATH_H

#include "Time.h"
#include "ItemID.h"

namespace tk {
namespace Router {
    
class Footpath {
public:
    Footpath() {
    }
    
    Footpath(ItemID startStopPlaceID, ItemID endStopPlaceID , Time duration, double distance)
             : startStopPlaceID_(startStopPlaceID)
             , endStopPlaceID_(endStopPlaceID)
             , duration_(duration)
             , distance_(distance)
    {
    }
    
    ItemID startStopPlaceID() const {
        return startStopPlaceID_;
    }
    
    ItemID endStopPlaceID() const {
        return endStopPlaceID_;
    }
    
    Time duration() const {
        return duration_;
    }
    
    double distance() const {
        return distance_;
    }
    
private:
    ItemID startStopPlaceID_;
    ItemID endStopPlaceID_;
    Time duration_;
    double distance_;
};
    
}
}

#endif /* TK_FOOTPATH_H */
