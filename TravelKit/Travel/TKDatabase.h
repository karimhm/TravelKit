/*
 *  TKDatabase.h
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <TravelKit/TKItem.h>
#import <TravelKit/TKStopPlace.h>

NS_ASSUME_NONNULL_BEGIN

@class TKStopPlace;

typedef void (^TKStopPlaceFetchHandler)(NSArray<TKStopPlace *> * __nullable result, NSError * __nullable error);

@interface TKDatabase : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithURL:(NSURL *)url;

- (BOOL)openDatabase:(NSError **)error;
- (BOOL)closeDatabase:(NSError **)error;

@property (nonatomic, readonly, nullable) NSURL *url;

@property (nonatomic, readonly, getter=isValid) BOOL valid;
@property (nonatomic, readonly) NSDictionary <NSString *, id> *properties;

- (void)fetchStopPlaceWithID:(TKItemID)itemID completion:(TKStopPlaceFetchHandler)completion;
- (void)fetchStopPlacesWithName:(NSString *)name completion:(TKStopPlaceFetchHandler)completion;
- (void)fetchStopPlacesWithLocation:(CLLocation *)location completion:(TKStopPlaceFetchHandler)completion;

- (void)fetchStopPlacesWithName:(NSString *)name completion:(TKStopPlaceFetchHandler)completion limit:(TKInt)limit;
- (void)fetchStopPlacesWithLocation:(CLLocation *)location completion:(TKStopPlaceFetchHandler)completion limit:(TKInt)limit;

@end

NS_ASSUME_NONNULL_END