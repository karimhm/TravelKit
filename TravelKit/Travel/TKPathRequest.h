/*
 *  TKPathRequest.h
 *  Created on 25/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKStation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKPathRequest : NSObject

+ (instancetype)requestWithSource:(TKStation *)source destination:(TKStation *)destination;

@property (strong, nonatomic) TKStation *source;
@property (strong, nonatomic) TKStation *destination;

@property (strong, nonatomic) NSDate *departureDate;

@end

NS_ASSUME_NONNULL_END
