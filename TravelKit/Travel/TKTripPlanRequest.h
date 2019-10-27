/*
 *  TKTripPlanRequest.h
 *  Created on 18/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <TravelKit/TKStopPlace.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TKTripPlanOptions) {
    TKTripPlanOptionsNone                   = 0,
    TKTripPlanOptionsOmitSameTripArrival    = 1 << 0
};

NS_SWIFT_NAME(TripPlanRequest)
@interface TKTripPlanRequest : NSObject

- (instancetype)initWithSource:(TKStopPlace *)source destination:(TKStopPlace *)destination;

@property (strong, nonatomic) TKStopPlace *source;
@property (strong, nonatomic) TKStopPlace *destination;

@property (strong, nonatomic) NSDate *date;

@property (nonatomic) TKTripPlanOptions options;

@property (nonatomic) TKInt limit;

@end

NS_ASSUME_NONNULL_END
