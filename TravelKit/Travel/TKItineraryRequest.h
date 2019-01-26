/*
 *  TKItineraryRequest.h
 *  Created on 18/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <TravelKit/TKStopPlace.h>

@interface TKItineraryRequest : NSObject

- (instancetype)initWithSource:(TKStopPlace *)source destination:(TKStopPlace *)destination;

@property (strong, nonatomic) TKStopPlace *source;
@property (strong, nonatomic) TKStopPlace *destination;

@property (strong, nonatomic) NSDate *date;

@end
