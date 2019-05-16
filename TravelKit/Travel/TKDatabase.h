/*
 *  TKDatabase.h
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <TravelKit/TKItem.h>
#import <TravelKit/TKStopPlace.h>
#import <TravelKit/TKCalendar.h>
#import <TravelKit/TKTripPlanRequest.h>
#import <TravelKit/TKTripPlan.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TKStopPlaceFetchHandler)(NSArray<TKStopPlace *> * __nullable result, NSError * __nullable error);
typedef void (^TKTripPlanFetchHandler)(TKTripPlan * __nullable result, NSError * __nullable error);
typedef void (^TKRouteFetchHandler)(NSArray<TKRoute *> * __nullable result, NSError * __nullable error);
typedef void (^TKCalendarFetchHandler)(NSArray<TKCalendar *> * __nullable result, NSError * __nullable error);

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

- (void)fetchStopPlacesWithCompletion:(TKStopPlaceFetchHandler)completion;
- (void)fetchStopPlaceWithID:(TKItemID)itemID completion:(TKStopPlaceFetchHandler)completion;
- (void)fetchStopPlacesWithName:(NSString *)name completion:(TKStopPlaceFetchHandler)completion;
- (void)fetchStopPlacesWithLocation:(CLLocation *)location completion:(TKStopPlaceFetchHandler)completion;
- (void)fetchStopPlacesWithName:(NSString *)name limit:(TKInt)limit completion:(TKStopPlaceFetchHandler)completion;
- (void)fetchStopPlacesWithLocation:(CLLocation *)location limit:(TKInt)limit completion:(TKStopPlaceFetchHandler)completion;

- (void)fetchRoutesWithCompletion:(TKRouteFetchHandler)completion;
- (void)fetchRouteWithID:(TKItemID)itemID completion:(TKRouteFetchHandler)completion;
- (void)fetchRoutesWithName:(NSString *)name completion:(TKRouteFetchHandler)completion;
- (void)fetchRoutesWithName:(NSString *)name limit:(TKInt)limit completion:(TKRouteFetchHandler)completion;

- (void)fetchCalendarsWithCompletion:(TKCalendarFetchHandler)completion;
- (void)fetchCalendarWithID:(TKItemID)itemID completion:(TKCalendarFetchHandler)completion;
- (void)fetchCalendarsWithName:(NSString *)name completion:(TKCalendarFetchHandler)completion;
- (void)fetchCalendarsWithName:(NSString *)name limit:(TKInt)limit completion:(TKCalendarFetchHandler)completion;

- (void)fetchTripPlanWithRequest:(TKTripPlanRequest *)request completion:(TKTripPlanFetchHandler)completion;
- (void)fetchTripPlanWithRequest:(TKTripPlanRequest *)request limit:(TKInt)limit completion:(TKTripPlanFetchHandler)completion;

@end

NS_ASSUME_NONNULL_END
