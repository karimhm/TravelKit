//
//  Copyright (C) 2019 Karim. All rights reserved.
//
//  This file is the property of Karim,
//  and is considered proprietary and confidential.
//
//  Created on 11/1/19 by Karim.
//

#import "TKJSRuntime.h"
#import "TKDatabase_Private.h"
#import "TKLogger.h"
#import "TravelKitClass.h"
#import "DatabaseClass.h"
#import "DeviceClass.h"

using namespace tk;

@implementation TKJSRuntime {
    TKDatabase *_db;
    JSGlobalContextRef _globalContext;
}

+ (JSContextGroupRef)contextGroup {
    static JSContextGroupRef _contextGroup;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _contextGroup = JSContextGroupCreate();
    });
    
    return _contextGroup;
}

-(instancetype)initWithDatabase:(TKDatabase *)database {
    if (self = [super init]) {
        _db = database;
        
        _globalContext = JSGlobalContextCreateInGroup([TKJSRuntime contextGroup], nullptr);
        JSGlobalContextSetName(_globalContext, JSStringCreateWithUTF8CString("TravelKit"));
        JSObjectRef globalObject = JSContextGetGlobalObject(_globalContext);
        JSObjectRef travelKitObject = JSRuntime::TravelKitObjectMake(_globalContext);
        
        JSObjectSetProperty(_globalContext,
                            globalObject,
                            JSStringCreateWithUTF8CString("TravelKit"),
                            travelKitObject,
                            kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete,
                            nullptr);
        
        JSObjectSetProperty(_globalContext,
                            travelKitObject,
                            JSStringCreateWithUTF8CString("database"),
                            JSRuntime::DatabaseObjectMake(_globalContext, _db),
                            kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete,
                            nullptr);
        
        JSObjectSetProperty(_globalContext,
                            travelKitObject,
                            JSStringCreateWithUTF8CString("device"),
                            JSRuntime::DeviceObjectMake(_globalContext),
                            kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete,
        nullptr);
    }
    return self;
}

- (void)dealloc {
    JSGlobalContextRelease(_globalContext);
}

@end
