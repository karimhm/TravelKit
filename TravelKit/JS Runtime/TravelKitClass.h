/*
 *  TravelKitClass.h
 *  Created on 6/Nov/2019.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TRAVEL_KIT_CLASS_H
#define TRAVEL_KIT_CLASS_H

#import <JavaScriptCore/JavaScriptCore.h>
#import <TravelKit/TKDatabase.h>
#import "ErrorOr.h"

namespace tk {
namespace JSRuntime {

JSClassRef GetTravelKitClass(void);
JSObjectRef TravelKitObjectMake(JSContextRef ctx);

}
}

#endif /* TRAVEL_KIT_CLASS_H */
