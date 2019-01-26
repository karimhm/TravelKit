/*
 *  StopTime.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_STOP_TIME_H
#define TK_STOP_TIME_H

#include "ItemID.h"
#include "Time.h"

namespace tk {

class StopTime {
public:
    StopTime() {
    }
    
    StopTime(ItemID stopPlaceID, ItemID tripID, Time time)
             : stopPlaceID_(stopPlaceID)
             , tripID_(tripID)
             , time_(time)
    {
    }
    
    const ItemID stopPlaceID() const {
        return stopPlaceID_;
    }
    
    const ItemID tripID() const {
        return tripID_;
    }
    
    const Time time() const {
        return time_;
    }
    
public:
    ItemID stopPlaceID_;
    ItemID tripID_;
    Time time_;
};

using StopTimeVector = std::vector<StopTime>;

}

#endif /* TK_STOP_TIME_H */
