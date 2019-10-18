/*
 *  TKQuery.h
 *  Created on 19/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <TravelKit/TKRoutePattern.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *TKOrderProperty NS_EXTENSIBLE_STRING_ENUM;

typedef NS_OPTIONS(NSUInteger, TKSortOrder) {
    TKSortOrderNone            = 0,
    TKSortOrderASC             = 1,
    TKSortOrderDESC            = 2
};

TK_EXTERN TKOrderProperty const TKOrderByName;

@interface TKQuery : NSObject

/*!
 @property
 @abstract   The identifier of the item.
 */
@property (nonatomic) TKItemID itemID;

/*!
 @property
 @abstract   The number of items to fetch.
 */
@property (nonatomic) TKInt limit;

/*!
 @property
 @abstract   The column used to order items.
 */
@property (nonatomic) TKOrderProperty orderBy;

/*!
 @property
 @abstract   The sort order, ascending or descending. default is TKSortOrderNone.
 */
@property (nonatomic) TKSortOrder sortOrder;

/*!
 @property
 @abstract   The name of the item.
 */
@property (nonatomic, nullable) NSString *name;

/*!
 @property
 @abstract   The travel direction. default is TKTravelDirectionUnknown.
 */
@property (nonatomic) TKTravelDirection direction;

@end

@interface TKQuery (StopPlace)

/*!
 @property
 @abstract   The identifier of the stop place.
 */
@property (nonatomic) TKItemID stopPlaceID;

/*!
 @property
 @abstract   The location of the stop place.
 */
@property (nonatomic, nullable) CLLocation *location;

@end

@interface TKQuery (Route)

/*!
 @property
 @abstract   The identifier of the route.
 */
@property (nonatomic) TKItemID routeID;

@end

@interface TKQuery (Trip)

/*!
 @property
 @abstract   The identifier of the trip.
 */
@property (nonatomic) TKItemID tripID;

@end

NS_ASSUME_NONNULL_END
