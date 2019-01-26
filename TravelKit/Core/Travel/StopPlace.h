/*
 *  StopPlace.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_STOP_PLACE_H
#define TK_STOP_PLACE_H

#include "ItemID.h"
#include <string>
#include <cmath>

namespace tk {

class Coordinate2D {
    using LocationDegrees = double;
    using LocationDistance = double;
    
public:
    explicit Coordinate2D() : latitude_(NAN), longitude_(NAN) {
        valid_ = false;
    }
    
    Coordinate2D(LocationDegrees latitude, LocationDegrees longitude)
                 : latitude_(latitude)
                 , longitude_(longitude)
    {
        valid_ = true;
    }
    
    const LocationDegrees latitude() const {
        return latitude_;
    }
    
    const LocationDegrees longitude() const {
        return longitude_;
    }
    
    const LocationDistance distance(Coordinate2D& other);
    
    bool isValid() const {
        return valid_;
    }
    
private:
    LocationDegrees latitude_;
    LocationDegrees longitude_;
    bool valid_;
};
    
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
