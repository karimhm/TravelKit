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

- (const void*)blobForColumn:(NSString *)columnName;
- (double)doubleForColumn:(NSString *)columnName;
- (int64_t)int64ForColumn:(NSString *)columnName;
- (const char *)textForColumn:(NSString *)columnName;

- (NSString *)stringForColumn:(NSString *)columnName;

@end
