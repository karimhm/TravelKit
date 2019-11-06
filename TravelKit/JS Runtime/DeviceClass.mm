/*
 *  DeviceClass.mm
 *  Created on 6/Nov/2019.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "DeviceClass.h"
#import "Defines.h"
#import <UIKit/UIKit.h>

using namespace tk;

static JSValueRef DeviceGetModel(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    NSString *model = [UIDevice currentDevice].model;
    if (model) {
        JSStringRef string = JSStringCreateWithUTF8CString(model.UTF8String);
        JSValueRef value = JSValueMakeString(ctx, string);
        JSStringRelease(string);
        return value;
    } else {
        return JSValueMakeNull(ctx);
    }
}

static JSValueRef DeviceGetSystemName(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    NSString *systemName = [UIDevice currentDevice].systemName;
    if (systemName) {
        JSStringRef string = JSStringCreateWithUTF8CString(systemName.UTF8String);
        JSValueRef value = JSValueMakeString(ctx, string);
        JSStringRelease(string);
        return value;
    } else {
        return JSValueMakeNull(ctx);
    }
}

static JSValueRef DeviceGetSystemVersion(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    if (systemVersion) {
        JSStringRef string = JSStringCreateWithUTF8CString(systemVersion.UTF8String);
        JSValueRef value = JSValueMakeString(ctx, string);
        JSStringRelease(string);
        return value;
    } else {
        return JSValueMakeNull(ctx);
    }
}

static JSValueRef DeviceGetBatteryState(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    JSStringRef string = nullptr;
    if (batteryState == UIDeviceBatteryStateUnplugged) {
        string = JSStringCreateWithUTF8CString("unplugged");
    } else if (batteryState == UIDeviceBatteryStateCharging) {
        string = JSStringCreateWithUTF8CString("charging");
    } else if (batteryState == UIDeviceBatteryStateFull) {
        string = JSStringCreateWithUTF8CString("full");
    } else {
        string = JSStringCreateWithUTF8CString("unknown");
    }
    JSValueRef value = JSValueMakeString(ctx, string);
    JSStringRelease(string);
    return value;
}

static JSValueRef DeviceGetBatteryLevel(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    return JSValueMakeNumber(ctx, [UIDevice currentDevice].batteryLevel);
}

JSClassRef JSRuntime::GetDeviceClass(void) {
    static JSClassRef deviceClass = nullptr;
    if (!deviceClass) {
        static JSStaticValue staticValues[] = {
            {"model", DeviceGetModel, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {"systemName", DeviceGetSystemName, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {"systemVersion", DeviceGetSystemVersion, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {"batteryState", DeviceGetBatteryState, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {"batteryLevel", DeviceGetBatteryLevel, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {0, 0, 0, 0}
        };
        
        JSClassDefinition classDefinition = kJSClassDefinitionEmpty;
        classDefinition.className = "Device";
        classDefinition.attributes = kJSClassAttributeNone;
        classDefinition.staticValues = staticValues;
        deviceClass = JSClassCreate(&classDefinition);
    }
    return deviceClass;
}

JSObjectRef JSRuntime::DeviceObjectMake(JSContextRef ctx) {
    return JSObjectMake(ctx, GetDeviceClass(), nullptr);
}

