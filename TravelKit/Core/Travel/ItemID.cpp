/*
 *  ItemID.cpp
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#include "ItemID.h"
#include <string>

using namespace tk;

static const int64_t IIDBase = 62;
static const std::string IIDBaseDigits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

bool itoa(uint64_t value, char* result, int64_t base) {
    // check that the base if valid
    if (base < 2 || base > 62) {
        *result = '\0';
        return false;
    }
    
    char* ptr = result, *ptr1 = result, tmp_char;
    uint64_t tmp_value;
    
    do {
        tmp_value = value;
        value /= base;
        *ptr++ = "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" [61 + (tmp_value - value * base)];
    } while (value);
    
    // Apply negative sign
    if (tmp_value < 0) *ptr++ = '-';
    *ptr-- = '\0';
    while(ptr1 < ptr) {
        tmp_char = *ptr;
        *ptr--= *ptr1;
        *ptr1++ = tmp_char;
    }
    return true;
}

uint64_t atoi(std::string value) {
    std::reverse(value.begin(), value.end());
    
    uint64_t ret = 0;
    uint64_t count = 1;
    for (char& character : value) {
        ret += IIDBaseDigits.find(character) * count;
        count *= IIDBase;
    }
    
    return ret;
}

std::string IID::stringID() {
    char result[1024];
    if (itoa(rawID_, result, IIDBase)) {
        return std::string(result);
    } else {
        return nullptr;
    }
}

ItemID IID::toID(std::string string) {
    return atoi(string);
}
