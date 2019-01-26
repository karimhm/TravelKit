/*
 *  Status.hpp
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_STATUS_H
#define TK_STATUS_H

#include "Defines.h"
#include <unistd.h>
#include <sqlite3.h>

namespace tk {
    
class Status {
public:
    Status() : statusCode_(SQLITE_OK) {
    }
    
    Status(int statusCode) : statusCode_(statusCode) {
    }
    
    bool isOK() const {
        return statusCode_ == SQLITE_OK;
    }
    
    bool isDone() const {
        return statusCode_ == SQLITE_DONE;
    }
    
    bool isRow() const {
        return statusCode_ == SQLITE_ROW;
    }
    
    bool isBusy() const {
        return statusCode_ == SQLITE_BUSY;
    }
    
    bool isLocked() const {
        return statusCode_ == SQLITE_LOCKED;
    }
    
    int statusCode() const {
        return statusCode_;
    }
    
private:
    int statusCode_;
};
    
}

#endif /* TK_STATUS_H */
