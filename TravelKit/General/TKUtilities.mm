/*
 *  TKUtilities.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKUtilities.h"
#import "TKConstants_Private.h"
#import "ItemID.h"
#import "TKItem.h"

TKTimeInfo TKTimeInfoCreate(NSTimeInterval time) {
    TKTimeInfo timeInfo;
    uint64_t _time = time;
    
    // Day
    uint64_t day = _time / TKSecondsInDay;
    _time = (_time % TKSecondsInDay);
    
    // Hour
    uint64_t hour = _time / TKSecondsInHour;
    _time = (_time % TKSecondsInHour);
    
    // Minute
    uint64_t minute = _time / TKSecondsInMinute;
    _time = (_time % TKSecondsInMinute);
    
    timeInfo.day = (uint32_t)day;
    timeInfo.hour = (uint32_t)hour;
    timeInfo.minute = (uint32_t)minute;
    timeInfo.second = (uint32_t)_time;
    
    return timeInfo;
}

int64_t TKTimeInfoGetDaystamp(TKTimeInfo timeInfo) {
    return (timeInfo.second) +
           (timeInfo.minute * TKSecondsInMinute) +
           (timeInfo.hour * TKSecondsInHour) +
           (timeInfo.day * TKSecondsInDay);
}

NSString *TKItemIdentifier(TKItem *item) {
    return [NSString stringWithUTF8String:tk::IID(item.identifier).stringID().c_str()];
}

TKItemID TKItemIDFromString(NSString *string) {
    return tk::IID(string.UTF8String).rawID();
}
