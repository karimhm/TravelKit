/*
 *  Statement.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_STATEMENT_H
#define TK_STATEMENT_H

#include "Defines.h"
#include "Ref.h"
#include "Database.h"
#include "Value.h"
#include <sqlite3.h>

namespace tk {
    
using ColumnMap = std::map<std::string, int32_t>;
    
class Statement : public RefCounted<Statement> {
public:
    Statement(Ref<Database> db, const char* format, ...) ;
    Statement(Ref<Database> db, std::string query) : db_(db), query_(query) {
    }
    
    ~Statement() {
        if (statement_) {
            sqlite3_finalize(statement_);
        }
    }

    Status bind(double value, std::string name) {
        return bind(value, static_cast<int32_t>(sqlite3_bind_parameter_index(statement_, name.c_str())));
    }
    
    Status bind(int32_t value, std::string name) {
        return bind(value, static_cast<int32_t>(sqlite3_bind_parameter_index(statement_, name.c_str())));
    }
    
    Status bind(int64_t value, std::string name) {
        return bind(value, static_cast<int32_t>(sqlite3_bind_parameter_index(statement_, name.c_str())));
    }
    
    Status bind(std::string value, std::string name) {
        return bind(value, static_cast<int32_t>(sqlite3_bind_parameter_index(statement_, name.c_str())));
    }
    
    Status bind(std::nullptr_t value, std::string name) {
        return bind(value, static_cast<int32_t>(sqlite3_bind_parameter_index(statement_, name.c_str())));
    }
    
    Status bindNull(std::string name) {
        return bindNull(static_cast<int32_t>(sqlite3_bind_parameter_index(statement_, name.c_str())));
    }
    
    Status bind(double value, int32_t index) {
        return static_cast<Status>(sqlite3_bind_double(statement_, (int)index, value));
    }
    
    Status bind(int32_t value, int32_t index) {
        return static_cast<Status>(sqlite3_bind_int(statement_, (int)index, value));
    }
    
    Status bind(int64_t value, int32_t index) {
        return static_cast<Status>(sqlite3_bind_int64(statement_, (int)index, value));
    }
    
    Status bind(std::string value, int32_t index) {
        return static_cast<Status>(sqlite3_bind_text64(statement_, (int)index, value.c_str(), (sqlite3_uint64)value.size(), SQLITE_TRANSIENT, SQLITE_UTF8));
    }
    
    Status bind(std::nullptr_t value, int32_t index) {
        return static_cast<Status>(sqlite3_bind_null(statement_, (int)index));
    }
    
    Status bindNull(int32_t index) {
        return static_cast<Status>(sqlite3_bind_null(statement_, (int)index));
    }
    
    operator sqlite3_stmt*() const {
        return statement_;
    }
    
    sqlite3_stmt* handle() const {
        return statement_;
    }
    
    Value const operator[](int32_t index) const {
        return tk::Value(statement_, index);
    }
    
    Value const operator[](std::string columnName) const {
        if (columnMap_.count(columnName)) {
            return tk::Value(statement_, columnMap()[columnName]);
        } else {
            return tk::Value(statement_, -1);
        }
    }
    
    int64_t size() const {
        return sqlite3_data_count(statement_);
    }
    
    Status prepare();
    
    Status execute() {
        Status status = sqlite3_step(statement_);
        
        return status;
    }

    Status next() {
        Status status = sqlite3_step(statement_);
        
        return status;
    }
    
    bool isBusy() const {
        return sqlite3_stmt_busy(statement_);
    }
    
    bool isReadOnly() const {
        return sqlite3_stmt_readonly(statement_);
    }
    
    bool isClosed() const {
        return closed_;
    }

    ColumnMap columnMap() const {
        return columnMap_;
    }
    
    std::string expandedQuery();
    
    std::string sql() {
        return sqlite3_sql(statement_);
    }

    Status clearAndReset() {
        Status status = clearBindings();
        
        if (status.isOK()) {
            status = reset();
        }
        
        return status;
    }
    
    Status clearBindings() {
        Status status = sqlite3_clear_bindings(statement_);
        
        return status;
    }
    
    Status reset() {
        Status status = sqlite3_reset(statement_);
        
        return status;
    }
    
    Status close();

private:
    bool closed_ = false;
    Ref<Database> db_ = nullptr;
    std::string query_;
    sqlite3_stmt* statement_ = nullptr;
    ColumnMap columnMap_;
};

}

#endif /* TK_STATEMENT_H */
