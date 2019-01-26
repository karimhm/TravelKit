/*
 *  Stop.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_STOP_H
#define TK_STOP_H

#include "Ref.h"
#include "ItemID.h"
#include "Time.h"
#include <vector>

namespace tk {

class Stop {
public:
    Stop() {
    }
    
    Stop(ItemID stopPlaceID, ItemID tripID, Time time)
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

using StopVector = std::vector<Stop>;

}

#endif /* TK_STOP_H */
