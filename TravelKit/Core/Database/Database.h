/*
 *  Database.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_DATABASE_H
#define TK_DATABASE_H

#include "Defines.h"
#include "Ref.h"
#include "Status.h"
#include "FunctionContext.h"
#include <sqlite3.h>
#include <unistd.h>

namespace tk {
    
enum Options : int32_t {
    None = 0,
    OpenReadOnly = 1 << 0,
    OpenReadWrite = 1 << 1,
    Create = 1 << 2
};

class Database : public RefCounted<Database> {
public:
    Database(std::string path) : path_(path), db_(nullptr) {
    }
    
    ~Database() {
        if (db_) {
            sqlite3_close(db_);
        }
    }
    
    Status open(Options options);
    Status close();

    Status execute(std::string format, ...);
    
    bool tableExist(std::string tableName);
    bool columnExist(std::string tableName, std::string columnName);

    Status addFunction(FunctionContext context);
    
    bool isOpen() const {
        return open_;
    }
    
    bool isValid() const {
        return valid_;
    }
    
    operator sqlite3*() const {
        return db_;
    }
    
    sqlite3* handle() const {
        return db_;
    }
    
    std::string path() const {
        return path_;
    }
    
private:
    std::string path_ = nullptr;
    Options options_ = Options::None;
    sqlite3* db_ = nullptr;
    bool open_ = false;
    bool valid_ = false;
};

}

#endif /* TK_DATABASE_H */
