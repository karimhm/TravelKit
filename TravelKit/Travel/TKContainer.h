/*
 *  TKContainer.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKStation.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface TKContainer : NSObject

- (instancetype)initWithPath:(NSString *)path error:(NSError **)error;
- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error;

@property (nonatomic, readonly, getter=isValid) BOOL valid;

@property (strong, nonatomic, readonly) NSSet <TKStation *> *stations;

@end
