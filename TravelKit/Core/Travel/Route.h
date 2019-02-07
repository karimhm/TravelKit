/*
 *  Route.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_ROUTE_H
#define TK_ROUTE_H

#include "ItemID.h"
#include "Trip.h"
#include <vector>

namespace tk {

class Route {
public:
    Route() {
    }
    
    Route(uint32_t color) : color_(color) {
    }
    
    uint32_t color() const {
        return color_;
    }
    
private:
    uint32_t color_;
};

using RouteVector = std::vector<Route>;

}

#endif /* TK_ROUTE_H */
