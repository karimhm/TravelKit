/*
 *  RefCounted.h
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#ifndef TK_REF_COUNTED_H
#define TK_REF_COUNTED_H

#include <unistd.h>

namespace tk {

template<typename T> class RefCounted {
public:
    void ref() const {
        ++refCount_;
    }
    
    void deref() const {
        if (!(refCount_ -= 1)) {
            delete static_cast<const T*>(this);
        }
    }
    
    uint32_t refCount() const {
        return refCount_;
    }
    
protected:
    RefCounted() : refCount_(1) {
    }
    
    RefCounted(RefCounted const &) : refCount_(1) {
    }
    
    RefCounted& operator= (RefCounted const&) {
        return *this;
    }
    
    ~RefCounted() {
    }
    
private:
    mutable uint32_t refCount_;
};

}

#endif /* TK_REF_COUNTED_H */
