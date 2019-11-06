/*
 *  DeviceClass.h
 *  Created on 6/Nov/2019.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef DEVICE_CLASS_H
#define DEVICE_CLASS_H

#import <JavaScriptCore/JavaScriptCore.h>
#import <TravelKit/TKDatabase.h>
#import "ErrorOr.h"

namespace tk {
namespace JSRuntime {

JSClassRef GetDeviceClass(void);
JSObjectRef DeviceObjectMake(JSContextRef ctx);

}
}

#endif /* DEVICE_CLASS_H */
