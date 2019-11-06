/*
 *  DatabaseClass.h
 *  Created on 1/Nov/2019.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef DATABASE_CLASS_H
#define DATABASE_CLASS_H

#import <JavaScriptCore/JavaScriptCore.h>
#import <TravelKit/TKDatabase.h>
#import "ErrorOr.h"

namespace tk {
namespace JSRuntime {

JSClassRef GetDatabaseClass(void);
JSObjectRef DatabaseObjectMake(JSContextRef ctx, TKDatabase *db);

}
}

#endif /* DATABASE_CLASS_H */
