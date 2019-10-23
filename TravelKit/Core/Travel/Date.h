/*
 *  Date.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_DATE_H
#define TK_DATE_H

#include <unistd.h>

namespace tk {
    
class Date {
public:
    Date() {
    }
    
    Date(uint16_t year, uint8_t month, uint8_t weekday, uint8_t day, uint32_t seconds)
         : year_(year)
         , month_(month)
         , weekday_(weekday)
         , day_(day)
         , seconds_(seconds)
    {
    }
    
    const uint16_t year() const {
        return year_;
    }
    
    const uint8_t month() const {
        return month_;
    }
    
    const uint8_t weekday() const {
        return weekday_;
    }
    
    const uint8_t day() const {
        return day_;
    }
    
    const uint32_t seconds() const {
        return seconds_;
    }
    
private:
    uint32_t year_;
    uint8_t month_;
    uint8_t weekday_;
    uint8_t day_;
    uint32_t seconds_;
};
    
}

#endif /* TK_DATE_H */

