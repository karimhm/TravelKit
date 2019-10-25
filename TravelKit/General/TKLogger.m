/*
 *  TKLogger.m
 *  Created on 25/Oct/2019.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKLogger.h"
#import "TKDefines_Private.h"
#import <os/log.h>

static os_log_t _osLog;
static dispatch_queue_t _logQueue;

TK_CONSTRUCTOR static void _initOSLog() {
    static dispatch_once_t _once;
    dispatch_once(&_once, ^{
        _osLog = os_log_create("com.karhm.TravelKit", "TravelKit");
        _logQueue = dispatch_queue_create("com.karhm.TravelKit.logger", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_logQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    });
}

#define TK_LOG_MESSAGE(__message, __osLogImpl)                                          \
    va_list args;                                                                       \
    va_start(args, __message);                                                          \
    NSString *logMessage = [[NSString alloc] initWithFormat:__message arguments:args];  \
                                                                                        \
    dispatch_async(_logQueue, ^{                                                        \
        __osLogImpl(_osLog, "%{public}s", logMessage.UTF8String);                       \
    });                                                                                 \
                                                                                        \
    va_end(args);

void TKLogDefault(NSString *message, ...) {
    TK_LOG_MESSAGE(message, os_log);
}

void TKLogInfo(NSString *message, ...) {
    TK_LOG_MESSAGE(message, os_log_info);
}

void TKLogError(NSString *message, ...) {
    TK_LOG_MESSAGE(message, os_log_error);
}

void TKLogFault(NSString *message, ...) {
    TK_LOG_MESSAGE(message, os_log_fault);
}

void TKLogDebug(NSString *message, ...) {
    TK_LOG_MESSAGE(message, os_log_debug);
}
