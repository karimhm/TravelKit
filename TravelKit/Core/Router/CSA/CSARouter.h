/*
 *  CSARouter.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_CSA_ROUTER_H
#define TK_CSA_ROUTER_H

#include "BaseRouter.h"
#include "Connection.h"
#include "Transfer.h"
#include "Calendar.h"
#include "Trip.h"
#include "Footpath.h"

namespace tk {
namespace Router {
    
    class JourneyPointer {
    public:
        Connection enter;
        Connection exit;
    };
    
/*
 * Implements the Connection Scan Algorithm algorithm
 */
class CSA final : public RefCounted<CSA>, public Base {
private:
    class Dataset {
    public:
        Dataset(Ref<Database> db) {
        }
        
        const std::vector<Footpath>& footpathsFor(ItemID stopPlaceID) {
            return footpathsByStopPlaceID_[stopPlaceID];
        }
        
        const Calendar& calendarByID(ItemID id) {
            return calendarsByID_[id];
        }
        
        const Trip& tripByID(ItemID id) {
            return tripsByID_[id];
        }
        
    private:
        std::vector<Connection> connections_;
        std::vector<Footpath> footpaths_;
        std::map<ItemID, std::vector<Footpath>> footpathsByStopPlaceID_;
        std::map<ItemID, Calendar> calendarsByID_;
        std::map<ItemID, Trip> tripsByID_;
    };
    
public:
    CSA(Ref<Database> db) : Base(db) {
    }
    
    ErrorOr<void> load();
    ErrorOr<void> unload();
    
    ErrorOr<TripPlan> query(ItemID source, ItemID destination, Date date, QueryOptions options);
    
private:
    ConnectionVector connections_;
    std::map<ItemID, Transfer> stopTransferByID_;
    std::map<ItemID, Calendar> calendarByID_;
    std::map<ItemID, Trip> tripsByID_;
    std::map<ItemID, std::vector<Footpath>> stopFootpathsByID_;
    std::map<ItemID, std::string> stopNameByID_;
    std::map<ItemID, std::string> routeNameByID_;
};

}
}

#endif /* TK_CSA_ROUTER_H */
