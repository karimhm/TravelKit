/*
 *  TKDBRow.h
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TKDBValueType) {
    TKDBValueTypeUnknown = -1,
    TKDBValueTypeNull = 0,
    TKDBValueTypeInteger,
    TKDBValueTypeFloat,
    TKDBValueTypeText,
    TKDBValueTypeBlob
};

@protocol TKDBRow <NSObject>
@required;

- (TKDBValueType)valueTypeForColumn:(NSString *)columnName;
- (TKDBValueType)valueTypeForColumnAtIndex:(NSInteger)columnIndex;

- (const void*)blobForColumn:(NSString *)columnName;
- (double)doubleForColumn:(NSString *)columnName;
- (int64_t)int64ForColumn:(NSString *)columnName;
- (const char *)textForColumn:(NSString *)columnName;
- (const void*)blobForColumnAtIndex:(NSInteger)columnIndex;
- (double)doubleForColumnAtIndex:(NSInteger)columnIndex;
- (int64_t)int64ForColumnAtIndex:(NSInteger)columnIndex;
- (const char *)textForColumnAtIndex:(NSInteger)columnIndex;

- (NSString *)stringForColumn:(NSString *)columnName;
- (NSString *)stringForColumnAtIndex:(NSInteger)columnIndex;

@end
