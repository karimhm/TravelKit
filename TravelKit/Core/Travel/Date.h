/*
 *  Date.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_DATE_H
#define TK_DATE_H

#include <time.h>
#include <limits>
#include <os/log.h>

namespace tk {
    
class Date {
public:
    Date() {
    }
    
    Date(time_t time) {
        time_ = time;
        struct tm* ti = localtime(&time_);
        
        year_ = ti->tm_year;
        month_ = ti->tm_mon;
        day_ = ti->tm_wday;
    }
    
    Date(uint16_t year, uint8_t month, uint8_t day)
         : year_(year)
         , month_(month)
         , day_(day)
    {
    }
    
    const uint16_t year() const {
        return year_;
    }
    
    const uint8_t month() const {
        return month_;
    }
    
    const uint8_t day() const {
        return day_;
    }
    
    const uint32_t seconds() const {
        return (time_ % 86400);
    }
    
    const time_t time() const {
        return time_;
    }
    
private:
    uint32_t year_;
    uint8_t month_;
    uint8_t day_;
    time_t time_;
};
    
}

#endif /* TK_DATE_H */

