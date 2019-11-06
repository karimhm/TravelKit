/*
 *  DatabaseClass.mm
 *  Created on 1/Nov/2019.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "DatabaseClass.h"
#import "Statement.h"
#import "Defines.h"

using namespace tk;

TK_ALWAYS_INLINE TKDatabase *DatabaseGetPrivate(JSObjectRef object) {
    TKDatabase *db = (__bridge TKDatabase*)JSObjectGetPrivate(object);
    return db;
}

static JSValueRef DatabaseGetUUID(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    TKDatabase *db = DatabaseGetPrivate(object);
    if (db.uuid) {
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(db.uuid.UUIDString.UTF8String));
    } else {
        return JSValueMakeNull(ctx);
    }
}

static JSValueRef DatabaseGetTimestamp(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    TKDatabase *db = DatabaseGetPrivate(object);
    if (db.timestamp) {
        return JSValueMakeNumber(ctx, db.timestamp.timeIntervalSince1970);
    } else {
        return JSValueMakeNull(ctx);
    }
}

static JSValueRef DatabaseGetTimeZone(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    TKDatabase *db = DatabaseGetPrivate(object);
    if (db.timeZone) {
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(db.timeZone.name.UTF8String));
    } else {
        return JSValueMakeNull(ctx);
    }
}

static JSValueRef DatabaseGetLanguages(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception){
    TKDatabase *db = DatabaseGetPrivate(object);
    // Restrict the number of accepted languages to 2048
    // since higher values might cause a stack overflow
    size_t count = MIN(2048, db.languages.count);
    JSValueRef arguments[count];
    for (size_t i = 0; i < count; i++) {
        arguments[i] = JSValueMakeString(ctx, JSStringCreateWithUTF8CString(db.languages[i].UTF8String));
    }
    return reinterpret_cast<JSValueRef>(JSObjectMakeArray(ctx, count, arguments, nullptr));
}

JSClassRef JSRuntime::GetDatabaseClass(void) {
    static JSClassRef databaseClass = nullptr;
    if (!databaseClass) {
        static JSStaticValue staticValues[] = {
            {"uuid", DatabaseGetUUID, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {"timestamp", DatabaseGetTimestamp, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {"timeZone", DatabaseGetTimeZone, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {"languages", DatabaseGetLanguages, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete},
            {0, 0, 0, 0}
        };
        
        JSClassDefinition classDefinition = kJSClassDefinitionEmpty;
        classDefinition.className = "Database";
        classDefinition.attributes = kJSClassAttributeNone;
        classDefinition.staticValues = staticValues;
        databaseClass = JSClassCreate(&classDefinition);
    }
    return databaseClass;
}

JSObjectRef JSRuntime::DatabaseObjectMake(JSContextRef ctx, TKDatabase *db) {
    return JSObjectMake(ctx, GetDatabaseClass(), (__bridge void *)(db));
}
