/*
 *  Time.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_TIME_H
#define TK_TIME_H

#include <time.h>
#include <limits>
#include <string>

namespace tk {
    
class Time {
public:
    static Time Infinity() {
        return Time(std::numeric_limits<uint32_t>::max());
    }
    
public:
    Time() {
        seconds_ = Time::Infinity().seconds();
    }
    
    Time(Time const &other) {
        seconds_ = other.seconds_;
    }
    
    Time(Time &other) {
        seconds_ = other.seconds_;
    }
    
    Time(uint32_t seconds) {
        seconds_ = seconds;
    }
    
    Time(uint8_t hour, uint8_t minute, uint8_t second) {
        seconds_ = (hour * 3600) + (minute * 60) + second;
    }
    
    bool operator<(Time const &other) const {
        return seconds_ < other.seconds_;
    }
    
    bool operator>(Time const &other) const {
        return seconds_ > other.seconds_;
    }
    
    bool operator<=(Time const &other) const {
        return seconds_ <= other.seconds_;
    }
    
    bool operator>=(Time const &other) const {
        return seconds_ >= other.seconds_;
    }
    
    bool operator==(Time const &other) const {
        return seconds_ == other.seconds_;
    }
    
    int32_t operator-(Time const &other) const {
        return seconds_ - other.seconds_;
    }
    
    int32_t operator-(uint32_t const &other) const {
        return seconds_ - other;
    }
    
    explicit operator uint32_t() const {
        return seconds_;
    }
    
    const uint32_t seconds() const {
        return seconds_;
    }
    
private:
    uint32_t seconds_;
};
    
}

#endif /* TK_TIME_H */
