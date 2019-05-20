/*
 *  TKRoute.h
 *  Created on 5/Feb/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <UIKit/UIColor.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKRoute : TKItem

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly, nullable) UIColor *color;

@end

NS_ASSUME_NONNULL_END
