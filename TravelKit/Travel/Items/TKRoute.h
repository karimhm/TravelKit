/*
 *  TKRoute.h
 *  Created on 5/Feb/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <UIKit/UIColor.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Route)
@interface TKRoute : TKItem

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly, nullable) NSString *routeDescription;
@property (strong, nonatomic, readonly, nullable) UIColor *color;

@end

NS_ASSUME_NONNULL_END
