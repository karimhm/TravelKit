/*
 *  TKContainer.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKStation.h>
#import <TravelKit/TKPathRequest.h>
#import <TravelKit/TKPathResponse.h>
#import <CoreLocation/CLLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TKStationFetchHandler)(NSArray<TKStation *> * __nullable result, NSError * __nullable error);
typedef void (^TKPathRequestHandler)(TKPathResponse * __nullable result, NSError * __nullable error);

@interface TKContainer : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithURL:(NSURL *)url;

- (BOOL)openDatabase:(NSError **)error;
- (BOOL)closeDatabase;

@property (nonatomic, readonly, getter=isValid) BOOL valid;

@property (nonatomic, readonly) NSDictionary <NSString *, id> *properties;

- (TKStation *)fetchStationWithId:(TKItemID)stationId error:(NSError **)error;
- (void)fetchStationsMatchingName:(NSString *)name limit:(TKInt)limit completion:(TKStationFetchHandler)completion;
- (void)fetchStationsMatchingName:(NSString *)name excluding:(TKItemID)stationId limit:(TKInt)limit completion:(TKStationFetchHandler)completion;
- (void)fetchStationsNearLocation:(CLLocation *)location limit:(TKInt)limit completion:(TKStationFetchHandler)completion;
- (void)fetchPathWithRequest:(TKPathRequest *)request completion:(TKPathRequestHandler)completion;

@end

NS_ASSUME_NONNULL_END
