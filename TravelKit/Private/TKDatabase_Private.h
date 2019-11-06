//
//  Copyright (C) 2019 Karim. All rights reserved.
//
//  This file is the property of Karim,
//  and is considered proprietary and confidential.
//
//  Created on 11/5/19 by Karim.
//

#import "TKDatabase.h"
#import "Database.h"

NS_ASSUME_NONNULL_BEGIN

@interface TKDatabase ()

@property (nonatomic, readonly) tk::Ref<tk::Database> database;

@end

NS_ASSUME_NONNULL_END
