/*
 *  BaseRouter.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_ROUTER_H
#define TK_ROUTER_H

#include "Database.h"
#include "ItemID.h"
#include "Date.h"
#include "TripPlan.h"
#include "ErrorOr.h"

namespace tk {
namespace Router {

class QueryOptions {
public:
    enum Options : uint64_t {
        None = 0,
        OmitSameTripArrival = 1 << 0,
        IgnoreTransferTime = 2 << 0
    };
    
public:
    QueryOptions(uint64_t limit = 0) : limit_(limit), options_(Options::None) {
    }
    
    bool omitSameTripArrival() {
        return options_ & Options::OmitSameTripArrival;
    }
    
    bool ignoreTransferTime() {
        return options_ & Options::IgnoreTransferTime;
    }
    
    void omitSameTripArrival(bool value) {
        if (value) {
            options_ &= ~Options::OmitSameTripArrival;
        } else {
            options_ |= Options::OmitSameTripArrival;
        }
    }
    
    void ignoreTransferTime(bool value) {
        if (value) {
            options_ |= Options::IgnoreTransferTime;
        } else {
            options_ &= ~Options::IgnoreTransferTime;
        }
    }
    
private:
    uint64_t limit_;
    uint64_t options_;
};
    
class Base  {
public:
    Base(Ref<Database> db) : db_(db), loaded_(false) {
    }
    
    ErrorOr<void> load() {
        return {};
    }
    
    ErrorOr<void> unload() {
        return {};
    }
    
    bool isLoaded() const {
        return loaded_;
    }
    
    virtual ErrorOr<TripPlan> query(ItemID source, ItemID destination, Date date, QueryOptions options) = 0;
    
protected:
    Ref<Database> db_;
    bool loaded_;
};

}
}
    
#endif /* TK_ROUTER_H */
