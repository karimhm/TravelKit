/*
 *  Transfer.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_TRANSFER_H
#define TK_TRANSFER_H

#include "ItemID.h"

namespace tk {

using TransferType = uint16_t;
    
/*
 Switch
 Platform
 Walk
*/

class Transfer {
public:
    Transfer() {
    }
    
    Transfer(ItemID startStopPlaceID, ItemID endStopPlaceID, double distance, uint32_t duration, TransferType type)
             : startStopPlaceID_(startStopPlaceID)
             , endStopPlaceID_(endStopPlaceID)
             , distance_(distance)
             , duration_(duration)
             , type_(type)
    {
    }
    
    const ItemID startStopPlaceID() const {
        return startStopPlaceID_;
    }
    
    const ItemID endStopPlaceID() const {
        return endStopPlaceID_;
    }
    
    const double distance() const {
        return distance_;
    }
    
    const uint32_t duration() const {
        return duration_;
    }
    
    const TransferType type() const {
        return type_;
    }
    
public:
    ItemID startStopPlaceID_;
    ItemID endStopPlaceID_;
    double distance_;
    uint32_t duration_;
    TransferType type_;
};

using TransferVector = std::vector<Transfer>;
    
}

#endif /* TK_TRANSFER_H */
