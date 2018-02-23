/*
 *  TKDBCursor.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKDBRow.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKDBCursor : NSEnumerator

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) NSArray <NSString *> *columnNames;
@property (nonatomic, readonly, getter=isClosed) BOOL closed;

- (id<TKDBRow>)next;
- (BOOL)hasNext;
- (BOOL)close;

@end

NS_ASSUME_NONNULL_END
