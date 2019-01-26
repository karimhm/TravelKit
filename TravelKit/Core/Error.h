/*
 *  Error.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_ERROR_H
#define TK_ERROR_H

#include <unistd.h>
#include <sqlite3.h>
#include <string>

namespace tk {

class Error {
public:
    Error(sqlite3* db) {
        code_ = sqlite3_errcode(db);
        message_ = sqlite3_errmsg(db);
    }
    
    const std::string message() const {
        return message_;
    }
    
    const int32_t code() const {
        return code_;
    }
    
    void log() const;
    
private:
    int32_t code_;
    std::string message_;
};

}

#endif /* TK_ERROR_H */
