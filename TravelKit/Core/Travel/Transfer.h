/*
 *  Transfer.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_TRANSFER_H
#define TK_TRANSFER_H

#include "ItemID.h"

namespace tk {

class Transfer {
public:
    Transfer() {
    }
    
    Transfer(ItemID startStopPlaceID, ItemID endStopPlaceID, uint32_t duration)
             : startStopPlaceID_(startStopPlaceID)
             , endStopPlaceID_(endStopPlaceID)
             , duration_(duration)
    {
    }
    
    const ItemID startStopPlaceID() const {
        return startStopPlaceID_;
    }
    
    const ItemID endStopPlaceID() const {
        return endStopPlaceID_;
    }
    
    const uint32_t duration() const {
        return duration_;
    }
    
public:
    ItemID startStopPlaceID_;
    ItemID endStopPlaceID_;
    uint32_t duration_;
};

using TransferVector = std::vector<Transfer>;
    
}

#endif /* TK_TRANSFER_H */
