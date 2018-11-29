/*
 *  DBKRow.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <DBKit/DBKDefines.h>
#import <Foundation/Foundation.h>

@protocol DBKRow <NSObject>
@required;

- (DBKValueType)valueTypeForColumn:(NSString *)columnName;
- (DBKValueType)valueTypeForColumnAtIndex:(DBKInt)columnIndex;

- (const void*)blobForColumn:(NSString *)columnName;
- (int)bytesForColumn:(NSString *)columnName;
- (double)doubleForColumn:(NSString *)columnName;
- (int64_t)int64ForColumn:(NSString *)columnName;
- (const char *)textForColumn:(NSString *)columnName;
- (const void*)blobForColumnAtIndex:(DBKInt)columnIndex;
- (int)bytesForColumnAtIndex:(DBKInt)columnIndex;
- (double)doubleForColumnAtIndex:(DBKInt)columnIndex;
- (int64_t)int64ForColumnAtIndex:(DBKInt)columnIndex;
- (const char *)textForColumnAtIndex:(DBKInt)columnIndex;

- (NSString *)stringForColumn:(NSString *)columnName;
- (NSString *)stringForColumnAtIndex:(DBKInt)columnIndex;
- (NSData *)dataForColumn:(NSString *)columnName;
- (NSData *)dataForColumnAtIndex:(DBKInt)columnIndex;

@end
