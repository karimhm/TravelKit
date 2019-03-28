/*
 *  OmitSameTripArrival.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_OMIT_SAME_TRIP_ARRIVAL_H
#define TK_OMIT_SAME_TRIP_ARRIVAL_H

#include "ItemID.h"
#include "Itinerary.h"
#include <set>

namespace tk {
namespace Router {
namespace Filter {

size_t TransfersInfinity = std::numeric_limits<size_t>::max();

class OmitSameTripArrival {
public:
    static void apply(std::vector<QueryRoute>& routes_) {
        if (!routes_.size()) {
            return;
        }
        
        std::set<ItemID> toKeep;
        
        size_t previousTransfers = TransfersInfinity;
        ItemID previousTrip = routes_.front().connections().back().tripID();
        size_t itineraryIndex = 0;
        size_t itinerariesSize = routes_.size();
        
        for (size_t i = 0; i < itinerariesSize; i++) {
            const ItemID tripID = routes_[i].connections().back().tripID();
            const size_t transfers = routes_[i].transfers();
            
            if (tripID == previousTrip && transfers < previousTransfers) {
                previousTransfers = transfers;
                itineraryIndex = i;
            } else if (previousTrip != tripID) {
                toKeep.insert(routes_[itineraryIndex].id());
                
                previousTrip = tripID;
                previousTransfers = transfers;
                itineraryIndex = i;
            }
            
            // The last Itinerary
            if (i == itinerariesSize -1) {
                toKeep.insert(routes_[itineraryIndex].id());
            }
        }
        
        auto iterator = std::remove_if(routes_.begin(), routes_.end(), [&toKeep] (const QueryRoute route) {
            return toKeep.count(route.id()) == 0;
        });
        
        routes_.erase(iterator, routes_.end());
    }
};

}
}
}

#endif /* TK_OMIT_SAME_TRIP_ARRIVAL_H */
