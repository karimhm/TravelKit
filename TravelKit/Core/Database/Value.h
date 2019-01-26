/*
 *  Statement.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_VALUE_H
#define TK_VALUE_H

#include "Defines.h"
#include <sqlite3.h>
#include <unistd.h>
#include <iostream>

namespace tk {

enum class ValueType : int32_t {
    Unknown = -1,
    Null = SQLITE_NULL,
    Integer = SQLITE_INTEGER,
    Float = SQLITE_FLOAT,
    Text = SQLITE_TEXT,
    Blob = SQLITE_BLOB
};

class Value {
public:
    Value() : value_(nullptr) {
    }
    
    Value(sqlite3_value* value) : value_(value) {
    }
    
    Value(sqlite3_stmt* statement, int32_t index) : value_(sqlite3_column_value(statement, index)) {
    }
    
    operator double() const {
        return doubleValue();
    }
    
    operator int32_t() const {
        return intValue();
    }
    
    operator int64_t() const {
        return int64Value();
    }
    
    operator std::string() const {
        return stringValue();
    }
    
    operator const void*() const {
        return blobValue();
    }
    
    double doubleValue() const {
        return sqlite3_value_double(value_);
    }
    
    int32_t intValue() const {
        return sqlite3_value_int(value_);
    }
    
    int64_t int64Value() const {
        return sqlite3_value_int64(value_);
    }
    
    std::string stringValue() const {
        if (isString()) {
            return std::string((const char*)sqlite3_value_text(value_));
        } else {
            return nullptr;
        }
    }
    
    const void* blobValue() const {
        if (isBlob()) {
            return sqlite3_value_blob(value_);
        } else {
            return nullptr;
        }
    }
    
    int32_t blobSize() {
        return sqlite3_value_bytes(value_);
    }
    
    bool isDouble() const {
        return type() == ValueType::Float;
    }
    
    bool isInteger() const {
        return type() == ValueType::Integer;
    }
    
    bool isString() const {
        return type() == ValueType::Text;
    }
    
    bool isBlob() const {
        return type() == ValueType::Blob;
    }
    
    bool isNull() const {
        return type() == ValueType::Null;
    }
    
    bool isValid() const {
        return type() != ValueType::Unknown;
    }
    
    ValueType type() const {
        if (value_ != nullptr) {
            return static_cast<ValueType>(sqlite3_value_type(value_));
        } else {
            return ValueType::Unknown;
        }
    }
    
    operator bool() const {
        return isValid();
    }
    
private:
    sqlite3_value* value_;
};

TK_INLINE std::ostream& operator<< (std::ostream& os, const Value& value) {
    switch (value.type()) {
        case ValueType::Null: os << "null"; break;
        case ValueType::Unknown: os << "unknown"; break;
            
        default: os << value.stringValue(); break;
    }
    return os;
}
    
TK_INLINE std::ostream& operator<< (std::ostream& os, const ValueType& valueType) {
    switch (valueType) {
        case ValueType::Null: os << "Null"; break;
        case ValueType::Integer: os << "Integer"; break;
        case ValueType::Float: os << "Float"; break;
        case ValueType::Text: os << "Text"; break;
        case ValueType::Blob: os << "Blob"; break;
            
        default: os << "Unknown"; break;
    }
    return os;
}

}

#endif /* TK_VALUE_H */
