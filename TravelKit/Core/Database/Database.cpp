/*
 *  Database.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#include "Database.h"
#include <stdarg.h>
#include <stdio.h>

using namespace tk;

TK_EXTERN const FunctionContext FunctionContextEmpty = {
    .name = nullptr,
    .valuesCount = 0,
    .deterministic = false,
    .execute = nullptr,
    .step = nullptr,
    .finalize = nullptr,
    .destroy = nullptr,
};

static int OptionsToSQLiteFlags(Database::Options options) {
    int flags = 0;

    if (options & Database::Options::OpenReadWrite) {
        flags |= SQLITE_OPEN_READWRITE;
    } else if (options & Database::Options::OpenReadOnly) {
        flags |= SQLITE_OPEN_READONLY;
    }
    
    if (options & Database::Options::Create) {
        flags |= SQLITE_OPEN_CREATE;
    }

     return flags;
}

Status Database::open(Options options) {
    options_ = options;
    
    int status = sqlite3_open_v2(path_.c_str(),
                                    &db_,
                                    OptionsToSQLiteFlags(options_),
                                    NULL);
    
    if (status == SQLITE_OK) {
        open_ = true;
        valid_ = true;
    } else {
        valid_ = false;
    }
    
    return status;
}

Status Database::close() {
    if (!db_) {
        return SQLITE_OK;
    }
    
    int status = sqlite3_close(db_);
    
    if (status == SQLITE_OK) {
        db_ = nullptr;
        open_ = false;
    }
    
    return Status(status);
}

Status Database::execute(std::string format, ...) {
    va_list args;
    va_start(args, format);
    char *str = sqlite3_mprintf(format.c_str(), args);
    va_end(args);
    
    Status status = sqlite3_exec(db_, str, nullptr, nullptr, nullptr);
    sqlite3_free(str);
    
    return status;
}

bool Database::tableExist(std::string tableName) {
    char *str = nullptr;
    asprintf(&str, "SELECT name FROM sqlite_master WHERE [type] = 'table' AND name = '%s'", tableName.c_str());
    sqlite3_stmt* stmt = nullptr;
    bool exist = false;
    
    if (sqlite3_prepare_v2(db_, str, static_cast<int>(strlen(str)), &stmt, nullptr) == SQLITE_OK) {
        exist = sqlite3_step(stmt) == SQLITE_ROW;
    }
    
    sqlite3_finalize(stmt);
    free(str);
    return exist;
}

bool Database::columnExist(std::string tableName, std::string columnName) {
    char *str = nullptr;
    asprintf(&str, "SELECT name FROM pragma_table_info('%s') WHERE name == '%s'", tableName.c_str(), columnName.c_str());
    sqlite3_stmt* stmt = nullptr;
    bool exist = false;
    
    if (sqlite3_prepare_v2(db_, str, static_cast<int>(strlen(str)), &stmt, nullptr) == SQLITE_OK) {
        exist = sqlite3_step(stmt) == SQLITE_ROW;
    }
    
    sqlite3_finalize(stmt);
    free(str);
    return exist;
}

Status Database::addFunction(FunctionContext context) {
    Status status = sqlite3_create_function_v2(db_,
                                               context.name,
                                               context.valuesCount,
                                               context.deterministic ? (SQLITE_UTF8 | SQLITE_DETERMINISTIC) : (SQLITE_UTF8),
                                               context.info,
                                               context.execute,
                                               context.step,
                                               context.finalize,
                                               context.destroy);
    
    return status;
}
