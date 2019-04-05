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
namespace Router {

class Connection {
public:
    enum class Type : uint16_t {
        Unknown = 0,
        Walk = 1,
        Ride = 2,
    };
    
public:
    class Compare {
    public:
        bool operator()(Connection& lhs, Connection& rhs) const {
            return lhs.startTime() < rhs.startTime();
        }
        
        bool operator()(const Connection& lhs, const Connection& rhs) const {
            return lhs.startTime() < rhs.startTime();
        }
    };
    
public:
    Connection() {
    }
    
    Connection(ItemID startStopPlaceID, ItemID endStopPlaceID , Time startTime, Time endTime , ItemID tripID, ItemID calendarID, Type type = Type::Ride)
               : startStopPlaceID_(startStopPlaceID)
               , endStopPlaceID_(endStopPlaceID)
               , startTime_(startTime)
               , endTime_(endTime)
               , tripID_(tripID)
               , calendarID_(calendarID)
               , type_(type)
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
    
    Type type() const {
        return type_;
    }
    
private:
    ItemID startStopPlaceID_;
    ItemID endStopPlaceID_;
    Time startTime_;
    Time endTime_;
    ItemID tripID_;
    ItemID calendarID_;
    Type type_;
};

using ConnectionVector = std::vector<Connection>;

}
}

#endif /* TK_CONNECTION_H */
