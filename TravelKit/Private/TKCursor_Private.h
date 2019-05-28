/*
 *  TKCursor_Private.h
 *  Created on 19/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import "TKCursor.h"
#import "TKQuery.h"
#import "TKQuery_Private.h"
#import "NSError+TravelKit.h"
#import "TKDefines_Private.h"
#import "Database.h"
#import "Statement.h"
#import "TKItem_Core.h"
#import "TKStopPlace.h"
#import "TKRoute.h"
#import "TKCalendar.h"
#import "TKRouteLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TKCursor <ObjectType> ()

+ (instancetype)cursorWithDatabase:(tk::Ref<tk::Database>)database query:(TKQuery *)query;
+ (instancetype)cursorWithDatabase:(tk::Ref<tk::Database>)database query:(TKQuery *)query error:(NSError **)error;
- (instancetype)initWithDatabase:(tk::Ref<tk::Database>)database query:(TKQuery *)query error:(NSError **)error;

@property (nonatomic) tk::Ref<tk::Database> database;
@property (nonatomic) tk::Ref<tk::Statement> statement;

@property (nonatomic, readonly) TKQuery *query;

@property (nonatomic, readonly) NSMutableArray<ObjectType> *fetchResult;

- (nullable ObjectType)createObjectWithStatement:(tk::Ref<tk::Statement>)statement;

- (void)setCompleted:(BOOL)completed;
- (BOOL)prepareWithQuery:(TKQuery *)query error:(NSError **)error;
- (BOOL)fetchAllWithError:(NSError **)error;
- (BOOL)close;

@end

@interface TKStopPlaceCursor : TKCursor<TKStopPlace *>
@end

@interface TKRouteCursor : TKCursor<TKRoute *>
@end

@interface TKCalendarCursor : TKCursor<TKCalendar *>
@end

@interface TKRouteLineCursor : TKCursor<TKRouteLine *>
@end

NS_ASSUME_NONNULL_END
