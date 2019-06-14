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
        OmitSameTripArrival = 1 << 0
    };
    
public:
    QueryOptions(uint64_t limit = 0, Options options = Options::None) : limit_(limit), options_(options) {
    }
    
    bool omitSameTripArrival() {
        return options_ & Options::OmitSameTripArrival;
    }
    
    void omitSameTripArrival(bool value) {
        if (value) {
            options_ &= ~Options::OmitSameTripArrival;
        } else {
            options_ |= Options::OmitSameTripArrival;
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
