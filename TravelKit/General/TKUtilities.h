/*
 *  TKUtilities.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKStructs.h"
#import <TravelKit/TKDefines.h>
#import <Foundation/Foundation.h>

TK_EXTERN TKTimeInfo TKTimeInfoCreate(NSTimeInterval time);
TK_EXTERN int64_t TKTimeInfoGetDaystamp(TKTimeInfo timeInfo);
