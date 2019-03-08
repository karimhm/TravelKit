/*
 *  Coordinate2D.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_COORDINATE_2D_H
#define TK_COORDINATE_2D_H

#include "ItemID.h"
#include <string>
#include <cmath>

namespace tk {
    
class Coordinate2D {
public:
    explicit Coordinate2D() : latitude_(NAN), longitude_(NAN) {
    }
    
    Coordinate2D(double latitude, double longitude) : latitude_(latitude) , longitude_(longitude) {
    }
    
    const double latitude() const {
        return latitude_;
    }
    
    const double longitude() const {
        return longitude_;
    }
    
    const double distance(const Coordinate2D& other) const;
    
    bool isValid() const {
        return !std::isnan(latitude_) && !std::isnan(longitude_);
    }
    
private:
    double latitude_;
    double longitude_;
};

}

#endif /* TK_COORDINATE_2D_H */
