/*
 *  TKDatabase.h
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <TravelKit/TKItem.h>
#import <TravelKit/TKQuery.h>
#import <TravelKit/TKCursor.h>
#import <TravelKit/TKStopPlace.h>
#import <TravelKit/TKStopTime.h>
#import <TravelKit/TKCalendar.h>
#import <TravelKit/TKTrip.h>
#import <TravelKit/TKRoutePattern.h>
#import <TravelKit/TKTripPlanRequest.h>
#import <TravelKit/TKTripPlan.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TKTripPlanFetchHandler)(TKTripPlan * __nullable result, NSError * __nullable error);

@interface TKDatabase : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithURL:(NSURL *)url;

- (BOOL)openDatabase:(NSError **)error;
- (BOOL)closeDatabase:(NSError **)error;

@property (nonatomic, readonly, nullable) NSURL *url;

@property (nonatomic, readonly, getter=isValid) BOOL valid;
@property (nonatomic, readonly) NSDictionary <NSString *, id> *properties;

@property (nonatomic, readonly) NSArray <NSString *> *languages;
@property (nonatomic, nullable) NSString *selectedLanguage;

- (TKCursor <TKStopPlace *> *)fetchStopPlaceWithQuery:(TKQuery *)query;
- (TKCursor <TKRoute *> *)fetchRouteWithQuery:(TKQuery *)query;
- (TKCursor <TKCalendar *> *)fetchCalendarWithQuery:(TKQuery *)query;
- (TKCursor <TKRoutePattern *> *)fetchRoutePatternWithQuery:(TKQuery *)query;
- (TKCursor <TKStopTime *> *)fetchStopTimeWithQuery:(TKQuery *)query;
- (TKCursor <TKTrip *> *)fetchTripWithQuery:(TKQuery *)query;

- (TKCursor <TKStopPlace *> *)fetchStopPlaceWithQuery:(TKQuery *)query error:(NSError **)error;
- (TKCursor <TKRoute *> *)fetchRouteWithQuery:(TKQuery *)query error:(NSError **)error;
- (TKCursor <TKCalendar *> *)fetchCalendarWithQuery:(TKQuery *)query error:(NSError **)error;
- (TKCursor <TKRoutePattern *> *)fetchRoutePatternWithQuery:(TKQuery *)query error:(NSError **)error;
- (TKCursor <TKStopTime *> *)fetchStopTimeWithQuery:(TKQuery *)query error:(NSError **)error;
- (TKCursor <TKTrip *> *)fetchTripWithQuery:(TKQuery *)query error:(NSError **)error;

- (void)fetchTripPlanWithRequest:(TKTripPlanRequest *)request completion:(TKTripPlanFetchHandler)completion;

@end

@interface TKDatabase (Properties)

@property (nonatomic, nullable, readonly) NSUUID *uuid;
@property (nonatomic, nullable, readonly) NSDate *timestamp;
@property (nonatomic, nullable, readonly) NSTimeZone *timeZone;

@end

NS_ASSUME_NONNULL_END
