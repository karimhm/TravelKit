/*
 *  TKCursor.h
 *  Created on 19/May/19.
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#import <TravelKit/TKItem.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Cursor)
@interface TKCursor<ObjectType> : NSEnumerator<ObjectType>

/*!
 @method
 @abstract     Fetch all objects and store them.
 */
- (void)fetchAllWithCompletion:(void (^ __nullable) (NSArray<ObjectType> * __nullable result, NSError * __nullable error))completion;

/*!
 @method
 @abstract     Fetch one objects and store it.
 @discussion   This method doesn't return an error.
 */
- (nullable ObjectType)fetchOne NS_SWIFT_UNAVAILABLE("Use fetchOne() instead")
NS_SWIFT_NAME(_fetchOne());

/*!
 @method
 @abstract     Fetch one objects and store it.
 */
- (nullable ObjectType)fetchOneWithError:(NSError **)error
NS_SWIFT_NAME(fetchOne());

/*!
 @method
 @result     Return the next item. Will return nil if the cursor did complete.
 */
- (nullable ObjectType)next;

/*!
 @property
 @abstract   An array of all the fetched objects.
 */
@property (nonatomic, nullable) NSArray<ObjectType> *result;

/*!
 @property
 @abstract   A boolean indicating if the end was reached.
 */
@property (nonatomic, readonly, getter=isCompleted) BOOL completed;

@end

NS_ASSUME_NONNULL_END
