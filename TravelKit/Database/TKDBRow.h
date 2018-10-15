/*
 *  TKDBRow.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <TravelKit/TKDefines.h>
#import <Foundation/Foundation.h>

@protocol TKDBRow <NSObject>
@required;

- (TKDBValueType)valueTypeForColumn:(NSString *)columnName;
- (TKDBValueType)valueTypeForColumnAtIndex:(TKInt)columnIndex;

- (const void*)blobForColumn:(NSString *)columnName;
- (int)bytesForColumn:(NSString *)columnName;
- (double)doubleForColumn:(NSString *)columnName;
- (int64_t)int64ForColumn:(NSString *)columnName;
- (const char *)textForColumn:(NSString *)columnName;
- (const void*)blobForColumnAtIndex:(TKInt)columnIndex;
- (int)bytesForColumnAtIndex:(TKInt)columnIndex;
- (double)doubleForColumnAtIndex:(TKInt)columnIndex;
- (int64_t)int64ForColumnAtIndex:(TKInt)columnIndex;
- (const char *)textForColumnAtIndex:(TKInt)columnIndex;

- (NSString *)stringForColumn:(NSString *)columnName;
- (NSString *)stringForColumnAtIndex:(TKInt)columnIndex;

@end
