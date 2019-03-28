/*
 *  QueryRoute.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_QUERY_ROUTE_H
#define TK_QUERY_ROUTE_H

#include "Connection.h"
#include "ItemID.h"

namespace tk {
namespace Router {

class QueryRoute {
public:
    QueryRoute(ItemID id, ConnectionVector connections, size_t transfers) : id_(id), connections_(connections), transfers_(transfers) {
    }
    
    const ItemID id() const {
        return id_;
    }
    
    ConnectionVector connections() const {
        return connections_;
    }
    
    size_t transfers() const {
        return transfers_;
    }
    
private:
    ItemID id_;
    ConnectionVector connections_;
    size_t transfers_;
};

}
}

#endif /* TK_QUERY_ROUTE_H */
