/*
 *  Error.cpp
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#include "Error.h"
#include <os/log.h>
#include <asl.h>

using namespace tk;

void Error::log() const {
    if (__builtin_available(iOS 9.0, *)) {
        os_log(OS_LOG_DEFAULT, "%{public}s", message_.c_str());
    } else {
        asl_log_message(ASL_LEVEL_DEBUG, "%s", message_.c_str());
    }
}
