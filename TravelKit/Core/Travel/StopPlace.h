/*
 *  StopPlace.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_STOP_PLACE_H
#define TK_STOP_PLACE_H

#include "ItemID.h"
#include "Coordinate2D.h"
#include <string>
#include <cmath>

namespace tk {
    
class StopPlace {
public:
    StopPlace() {
    }
    
    StopPlace(std::string name) : name_(name) {
    }
    
    const std::string name() const {
        return name_;
    }
    
    const Coordinate2D location() const {
        return location_;
    }
    
private:
    std::string name_;
    Coordinate2D location_;
};

using StopPlaceVector = std::vector<StopPlace>;

}

#endif /* TK_STOP_PLACE_H */
