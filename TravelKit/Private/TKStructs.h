/*
 *  TKStructs.h
 *  Created on 12/Apr/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#include <TravelKit/TKDefines.h>
#include <stdint.h>

typedef struct {
    uint32_t second;
    uint32_t hour;
    uint32_t minute;
    uint32_t day;
} TKTimeInfo;
