/*
 *  ErrorOr.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_ERROR_OR
#define TK_ERROR_OR

#include "Error.h"
#include "expected.h"

namespace tk {

template<typename T> class ErrorOr {
public:
    ErrorOr(Error&& error) : value_(error) {
    }
    
    ErrorOr(T&& value) : value_(value) {
    }
    
    bool hasValue() const {
        return value_.has_value();
    }
    
    bool hasError() const {
        return !value_.has_value();
    }
    
    T value() const {
        return value_.value();
    }
    
    T&& releaseValue() {
        return std::move(value_.value());
    }
    
    const Error& error() const {
        return value_.error();
    }
    
    Error&& releaseError() {
        return std::move(value_.error());
    }
    
private:
    tl::expected<T, Error> value_;
};

template<> class ErrorOr<void> {
public:
    ErrorOr(Error&& error) : value_(tl::make_unexpected(std::move(error))) {
    }
    
    ErrorOr() = default;
    
    bool hasError() const {
        return !value_.has_value();
    }
    
    const Error& error() const {
        return value_.error();
    }
    
    Error&& releaseError() {
        return std::move(value_.error());
    }
    
private:
    tl::expected<void, Error> value_;
};

}

#endif /* TK_ERROR_OR */
