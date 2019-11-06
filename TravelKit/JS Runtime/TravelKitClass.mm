/*
 *  TravelKitClass.mm
 *  Created on 6/Nov/2019.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TravelKitClass.h"
#import "Defines.h"
#import <UIKit/UIKit.h>

using namespace tk;

static JSValueRef TravelKitGetVersion(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    if (version) {
        JSStringRef string = JSStringCreateWithUTF8CString(version.UTF8String);
        JSValueRef value = JSValueMakeString(ctx, string);
        JSStringRelease(string);
        return value;
    } else {
        return JSValueMakeNull(ctx);
    }
}

static JSValueRef TravelKitGetBuild(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    NSString *build = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    if (build) {
        JSStringRef string = JSStringCreateWithUTF8CString(build.UTF8String);
        JSValueRef value = JSValueMakeString(ctx, string);
        JSStringRelease(string);
        return value;
    } else {
        return JSValueMakeNull(ctx);
    }
}

JSClassRef JSRuntime::GetTravelKitClass(void) {
    static JSClassRef travelKitClass = nullptr;
    if (!travelKitClass) {
        static JSStaticValue staticValues[] = {
            {"version", TravelKitGetVersion, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {"build", TravelKitGetBuild, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {0, 0, 0, 0}
        };
        
        JSClassDefinition classDefinition = kJSClassDefinitionEmpty;
        classDefinition.className = "TravelKit";
        classDefinition.attributes = kJSClassAttributeNone;
        classDefinition.staticValues = staticValues;
        travelKitClass = JSClassCreate(&classDefinition);
    }
    return travelKitClass;
}

JSObjectRef JSRuntime::TravelKitObjectMake(JSContextRef ctx) {
    return JSObjectMake(ctx, GetTravelKitClass(), nullptr);
}
