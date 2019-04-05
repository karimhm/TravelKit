/*
 *  Calendar.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_CALENDAR_H
#define TK_CALENDAR_H

#include "Defines.h"
#include "Ref.h"
#include "Time.h"
#include "Date.h"
#include <vector>

namespace tk {

class DateCondition {
public:
    static constexpr uint32_t DaysMask = 0x1;
    
    enum class Condition : uint16_t {
        Add = 1,
        Remove = 2,
    };
    
public:
    DateCondition() {
    }
    
    DateCondition(Condition condition, uint16_t year, uint8_t month, uint8_t day)
                  : condition_(condition)
                  , year_(year)
                  , month_(month)
                  , day_(day)
    {
    }
    
    const bool isAvailable(Date date) const {
        if (condition_ == Condition::Remove) {
            return (date.day() != day_ && date.month() != month_ && date.year() != year_);
        } else if (condition_ == Condition::Add) {
            return (date.day() == day_ && date.month() == month_ && date.year() != year_);
        } else {
            return false;
        }
    }
    
private:
    Condition condition_;
    uint16_t year_;
    uint8_t month_;
    uint8_t day_;
};
    
class Calendar {
public:
    Calendar() {
    }
    
    Calendar(ItemID id, uint8_t days)
             : id_(id)
             , days_(days)
    {
    }
    
    const bool isAvailable(Date date) const {
        if ((DateCondition::DaysMask << date.day()) & days_) {
            return true;
        } else {
            return false;
        }
    }
    
    const ItemID id() const {
        return id_;
    }
    
    const uint8_t days() const {
        return days_;
    }
    
private:
    ItemID id_;
    uint8_t days_;
};

using CalendarVector = std::vector<Calendar>;
    
}

#endif /* TK_CALENDAR_H */
