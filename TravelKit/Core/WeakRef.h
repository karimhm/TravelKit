/*
 *  WeakRef.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_WEAK_REF_H
#define TK_WEAK_REF_H

#include "Ref.h"

namespace tk {
    
template<typename T>
class WeakRef {
public:
    WeakRef() : ptr_(nullptr) {
    }
    
    WeakRef(WeakRef const& other): ptr_(other.ptr_) {
    }
    
    WeakRef(WeakRef&& other) : ptr_(other.ptr_) {
    }
    
    WeakRef(Ref<T> const& other): ptr_(other.get()) {
    }
    
    T& operator*() const {
        return *ptr_;
    }
    
    T* operator->() const {
        return ptr_;
    }
    
    operator T&() const {
        return *ptr_;
    }
    
    operator bool() const {
        return ptr_ != nullptr;
    }
    
    WeakRef& operator=(WeakRef const & other) {
        ptr_ = other.ptr_;
        return *this;
    }
    
    WeakRef& operator=(WeakRef&& other) {
        ptr_ = other.ptr_;
        return *this;
    }
    
    WeakRef& operator=(Ref<T> const & other) {
        ptr_ = other.get();
        return *this;
    }
    
    WeakRef& operator=(Ref<T>&& other) {
        ptr_ = other.get();
        return *this;
    }
    
    T* get() const {
        return ptr_;
    }
    
private:
    T* ptr_;
};

template<class T, class U> inline bool operator==(WeakRef<T> const& a, WeakRef<U> const& b) {
    return a.get() == b.get();
}

template<class T, class U> inline bool operator!=(WeakRef<T> const& a, WeakRef<U> const& b) {
    return a.get() != b.get();
}

template<class T, class U> inline bool operator==(WeakRef<T> const& a, U* b) {
    return a.get() == b;
}

template<class T, class U> inline bool operator!=(WeakRef<T> const& a, U* b) {
    return a.get() != b;
}

template<class T, class U> inline bool operator==(T* a, WeakRef<U> const& b) {
    return a == b.get();
}

template<class T, class U> inline bool operator!=(T* a, WeakRef<U> const& b) {
    return a != b.get();
}
    
template<class T, class U> inline bool operator==(WeakRef<T> const& a, Ref<U> const& b) {
    return a.get() == b.get();
}

template<class T, class U> inline bool operator!=(WeakRef<T> const& a, Ref<U> const& b) {
    return a.get() != b.get();
}

template<class T, class U> inline bool operator==(Ref<T> const& a, WeakRef<U> const& b) {
    return a.get() == b.get();
}

template<class T, class U> inline bool operator!=(Ref<T> const& a, WeakRef<U> const& b) {
    return a.get() != b.get();
}
    
}

#endif /* TK_WEAK_REF_H */
