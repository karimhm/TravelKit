/*
 *  Ref.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_REF_H
#define TK_REF_H

#include "Defines.h"
#include "RefCounted.h"
#include <iostream>

namespace tk {
    
template<typename T>
class Ref {
public:
    Ref() : ptr_(nullptr) {
    };
    
    Ref(T* object, bool addRef = true) : ptr_(object) {
        if (ptr_ && addRef) {ptr_->ref();}
    }
    
    template<class U>
    Ref(Ref<U> const & other) : ptr_(other.get()) {
        if(ptr_) {ptr_->ref();}
    }
    
    Ref(Ref const & other): ptr_(other.ptr_) {
        if(ptr_) {ptr_->ref();}
    }
    
    Ref(Ref&& other) : ptr_(other.detach()) {
    }
    
    ~Ref() {
        if (ptr_) {ptr_->deref();}
    }
    
    T& operator*() const {
        return *ptr_;
    }
    
    T* operator->() const {
        return ptr_;
    }
    
    operator T&() const {
        return *ptr_;
    };
    
    operator bool() const {
        return ptr_ != nullptr;
    };
    
    Ref& operator=(Ref const & other) {
        Ref(other).swap(*this);
        return *this;
    }
    
    Ref& operator=(T* object){
        Ref(object).swap(*this);
        return *this;
    }
    
    Ref& operator=(Ref&& other) {
        Ref movedReference = std::move(other);
        swap(movedReference);
        return *this;
    }
    
    T* get() const {
        return ptr_;
    }
    
    TK_WARN_UNUSED_RETURN T* detach() {
        T* ret = ptr_;
        ptr_ = nullptr;
        return ret;
    }
    
    TK_ALWAYS_INLINE void swap(Ref & other) {
        T* tmp = ptr_;
        ptr_ = other.ptr_;
        other.ptr_ = tmp;
    }
    
private:
    T* ptr_;
};

template<class T, class U> inline bool operator==(Ref<T> const& a, Ref<U> const& b) {
    return a.get() == b.get();
}

template<class T, class U> inline bool operator!=(Ref<T> const& a, Ref<U> const& b) {
    return a.get() != b.get();
}

template<class T, class U> inline bool operator==(Ref<T> const& a, U* b) {
    return a.get() == b;
}

template<class T, class U> inline bool operator!=(Ref<T> const& a, U* b) {
    return a.get() != b;
}

template<class T, class U> inline bool operator==(T* a, Ref<U> const& b) {
    return a == b.get();
}

template<class T, class U> inline bool operator!=(T* a, Ref<U> const& b) {
    return a != b.get();
}

template<typename T, typename... Arg>
Ref<T> makeRef(Arg&&... args) {
    return Ref<T>(new T(std::forward<Arg>(args)...));
}

}

#endif /* TK_REF_H */
