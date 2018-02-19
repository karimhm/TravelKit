/*
 *  TKDBErrorReporter.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>

@protocol TKDBErrorReporter <NSObject>

- (void)reportError:(NSError *)error;

@end
