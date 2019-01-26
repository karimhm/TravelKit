/*
 *  ItemID.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_ITEM_ID_H
#define TK_ITEM_ID_H

#include <Security/SecRandom.h>
#include <string>
#include <ctime>

namespace tk {

using ItemID = uint64_t;

class IID {
public:
    IID() : rawID_(0) {}
    IID(ItemID rawID) : rawID_(rawID) {}
    
    IID(uint32_t time = uint32_t(std::time(0)),uint16_t counter = 0) {
        uint16_t random;
        if (SecRandomCopyBytes(kSecRandomDefault, 2, &random) == 0) {
            rawID_ = uint64_t(time) | uint64_t(random) << 32 | uint64_t(counter) << 48;
        }
    }
    
    int compare(const IID& other) const {
        if (rawID_ < other.rawID_) {
            return -1;
        } else if (rawID_ == other.rawID_) {
            return 0;
        } else {
            return 1;
        }
    }
    
    ItemID rawID() {
        return rawID_;
    }
    
    std::string stringID();
    
private:
    ItemID rawID_;
};

inline bool operator==(const IID& lhs, const IID& rhs) {
    return lhs.compare(rhs) == 0;
}

inline bool operator!=(const IID& lhs, const IID& rhs) {
    return lhs.compare(rhs) != 0;
}

inline bool operator<(const IID& lhs, const IID& rhs) {
    return lhs.compare(rhs) < 0;
}

inline bool operator<=(const IID& lhs, const IID& rhs) {
    return lhs.compare(rhs) <= 0;
}

}

#endif /* TK_ITEM_ID_H */
