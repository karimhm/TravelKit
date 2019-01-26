/*
 *  Statement.cpp
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#include "Statement.h"
#include "Database.h"
#include <stdarg.h>
#include <stdio.h>

using namespace tk;

Statement::Statement(Ref<Database> db, const char* format, ...) {
    va_list args;
    va_start(args, format);
    char *str = nullptr;
    vasprintf(&str, format, args);
    va_end(args);
    
    query_ = std::string(str);
    db_ = db;
    
    free(str);
}

Status Statement::prepare() {
    Status status = sqlite3_prepare_v2(db_->handle(), query_.c_str(), static_cast<int>(query_.size()), &statement_, nullptr);
    
    if (status.isOK()) {
        int32_t columnCount_ = sqlite3_column_count(statement_);
        
        for (int32_t colIndex = 0; colIndex < columnCount_; colIndex++) {
            std::string columnName = std::string(sqlite3_column_name(statement_, colIndex));
            columnMap_[columnName] = colIndex;
        }
    }
    
    return status;
}

std::string Statement::expandedQuery() {
    if (__builtin_available(iOS 10.0, *)) {
        return sqlite3_expanded_sql(statement_);
    } else {
        return nullptr;
    }
}
