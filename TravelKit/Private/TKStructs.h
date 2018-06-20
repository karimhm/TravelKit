/*
 *  TKStructs.h
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#include <TravelKit/TKDefines.h>
#include <stdint.h>

typedef struct {
    uint32_t stationId;
    uint32_t index;
} TKStationNode;

typedef struct {
    uint32_t hour;
    uint32_t minute;
    uint32_t day;
    uint32_t monthDay;
    uint32_t month;
} TKTimeInfo;

enum {
    TKConditionEqualAnd,
    TKConditionNotEqualAnd,
    TKConditionEqualOr,
    TKConditionNotEqualOr
};
typedef uint8_t TKCondition;

typedef struct {
#if defined(TK_BIG_ENDIAN)
    uint8_t day;
    uint8_t month;
    TKCondition condtion;
    uint8_t unused;
#elif defined(TK_LITTLE_ENDIAN)
    uint8_t unused;
    TKCondition condtion;
    uint8_t month;
    uint8_t day;
#endif
} TK_PACKED TKDateCondition;
