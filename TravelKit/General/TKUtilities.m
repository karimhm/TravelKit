/*
 *  TKUtilities.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKUtilities.h"

BOOL TKFileExists(NSString *path) {
    return (access(path.fileSystemRepresentation, F_OK ) != -1);
}

BOOL TKFileReadable(NSString *path) {
    return (access(path.fileSystemRepresentation, R_OK ) != -1);
}

BOOL TKFileWritable(NSString *path) {
    return (access(path.fileSystemRepresentation, W_OK ) != -1);
}

TKTimeInfo TKTimeInfoCreate(NSTimeInterval time) {
    TKTimeInfo timeInfo;
    
    time_t unixTime = (time_t)time;
    struct tm* ti = localtime(&unixTime);
    
    timeInfo.hour = ti->tm_hour;
    timeInfo.minute = ti->tm_min;
    timeInfo.day = ti->tm_wday;
    timeInfo.monthDay = ti->tm_mday;
    timeInfo.month = ti->tm_mon;
    
    return timeInfo;
}

int64_t TKTimeInfoGetDaystamp(TKTimeInfo timeInfo) {
    return (timeInfo.minute * 60) + (timeInfo.hour * 3600);
}
