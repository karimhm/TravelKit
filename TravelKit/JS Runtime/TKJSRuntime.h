//
//  Copyright (C) 2019 Karim. All rights reserved.
//
//  This file is the property of Karim,
//  and is considered proprietary and confidential.
//
//  Created on 11/1/19 by Karim.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <TravelKit/TKDatabase.h>

@interface TKJSRuntime : NSObject

-(instancetype)initWithDatabase:(TKDatabase *)database;

@end
