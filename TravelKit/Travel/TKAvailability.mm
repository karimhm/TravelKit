/*
 *  TKAvailability.m
 *  Created on 19/May/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKAvailability.h"
#import "TKItem_Private.h"
#import "TKUtilities.h"
#import <vector>

typedef std::vector<TKDateCondition> TKConditionVector;

@implementation TKAvailability {
    uint32_t _days;
    TKConditionVector _conditions;
}

- (instancetype)initWithRow:(id <TKDBRow>)row manager:(id <TKItemManager>)manager {
    if (self = [super initWithRow:row manager:manager]) {
        _name = [row stringForColumn:kTKColumnName];
        _days = (uint32_t)[row int64ForColumn:kTKColumnDays];
        
        TKDateCondition *conditions = (TKDateCondition*)[row blobForColumn:kTKColumnDates];
        uint32_t length = ([row bytesForColumn:kTKColumnDates] &~ 3) >> 2;
        
        for (uint32_t i = 0; i < length; i++) {
            TKDateCondition condition = {
                .day = conditions[i].day,
                .month = conditions[i].month,
                .condtion = conditions[i].condtion,
            };
            
            _conditions.push_back(condition);
        }
    }
    return self;
}

- (BOOL)availableAtDate:(NSDate *)date {
    TKTimeInfo timeInfo = TKTimeInfoCreate(date.timeIntervalSince1970);
    
    BOOL available = (TKDaysMask << timeInfo.day) & _days;
    
    for(TKDateCondition const& condition: _conditions) {
        switch (condition.condtion) {
            case TKConditionEqualAnd:
                if ((condition.day == timeInfo.monthDay) && (condition.month == timeInfo.month)) {
                    available = true;
                } else {
                    return false;
                }
            break;
                
            case TKConditionNotEqualAnd:
                if ((condition.day == timeInfo.monthDay) && (condition.month == timeInfo.month)) {
                    return false;
                }
            break;
                
            case TKConditionEqualOr:
                if ((condition.day == timeInfo.monthDay) && (condition.month == timeInfo.month)) {
                    available = true;
                }
            break;
                
            case TKConditionNotEqualOr:
                if ((condition.day != timeInfo.monthDay) && (condition.month != timeInfo.month)) {
                    available = true;
                }
            break;
                
            default:
                return false;
            break;
        }
    }
    
    return available;
}

#pragma mark - description

#ifdef DEBUG
- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p; id: %lli; days: %i; name: %@>", [self class], self, self.identifier, _days, _name];
}
#endif

@end
