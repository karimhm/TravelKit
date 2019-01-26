/*
 *  Connection.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_CONNECTION_H
#define TK_CONNECTION_H

#include "Ref.h"
#include "Time.h"
#include "ItemID.h"

namespace tk {

class Connection {
public:
    Connection() {
    }
    
    Connection(ItemID startStopPlaceID, ItemID endStopPlaceID , Time startTime, Time endTime , ItemID tripID, ItemID calendarID)
               : startStopPlaceID_(startStopPlaceID)
               , endStopPlaceID_(endStopPlaceID)
               , startTime_(startTime)
               , endTime_(endTime)
               , tripID_(tripID)
               , calendarID_(calendarID)
    {
    }
    
    Time startTime() const {
        return startTime_;
    }
    
    Time endTime() const {
        return endTime_;
    }
    
    ItemID startStopPlaceID() const {
        return startStopPlaceID_;
    }
    
    ItemID endStopPlaceID() const {
        return endStopPlaceID_;
    }
    
    ItemID tripID() const {
        return tripID_;
    }
    
    ItemID calendarID() const {
        return calendarID_;
    }
    
private:
    ItemID startStopPlaceID_;
    ItemID endStopPlaceID_;
    Time startTime_;
    Time endTime_;
    ItemID tripID_;
    ItemID calendarID_;
};

using ConnectionVector = std::vector<Connection>;

}

#endif /* TK_CONNECTION_H */
