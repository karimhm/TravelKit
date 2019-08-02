/*
 *  Mapping.h
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#ifndef TK_MAPPING_H
#define TK_MAPPING_H

#include "Statement.h"

namespace tk {
    
class StopTimeMapping {
public:
    StopTimeMapping(Ref<Statement> statement) {
        stopPlaceIDIndex_ = statement->columnMap()["stopPlaceId"];
        tripIDIndex_ = statement->columnMap()["tripId"];
        arrivalTimeIndex_ = statement->columnMap()["arrivalTime"];
        departureTimeIndex_ = statement->columnMap()["departureTime"];
        positionIndex_ = statement->columnMap()["position"];
    }
    
    const int32_t stopPlaceIDIndex() const {
        return stopPlaceIDIndex_;
    }
    
    const int32_t tripIDIndex() const {
        return tripIDIndex_;
    }
    
    const int32_t arrivalTimeIndex() const {
        return arrivalTimeIndex_;
    }
    
    const int32_t departureTimeIndex() const {
        return departureTimeIndex_;
    }
    
    const int32_t positionIndex () const {
        return positionIndex_;
    }
    
private:
    int32_t stopPlaceIDIndex_;
    int32_t tripIDIndex_;
    int32_t arrivalTimeIndex_;
    int32_t departureTimeIndex_;
    int32_t positionIndex_;
};

class TripMapping {
public:
    TripMapping(Ref<Statement> statement) {
        idIndex_ = statement->columnMap()["id"];
        calendarIDIndex_ = statement->columnMap()["calendarId"];
        routeIDIndex_ = statement->columnMap()["routeId"];
    }
    
    const int32_t idIndex() const {
        return idIndex_;
    }
    
    const int32_t calendarIDIndex() const {
        return calendarIDIndex_;
    }
    
    const int32_t routeIDIndex() const {
        return routeIDIndex_;
    }
    
private:
    int32_t idIndex_;
    int32_t calendarIDIndex_;
    int32_t routeIDIndex_;
};

class CalendarMapping {
public:
    CalendarMapping(Ref<Statement> statement) {
        idIndex_ = statement->columnMap()["id"];
        nameIndex_ = statement->columnMap()["name"];
        daysIndex_ = statement->columnMap()["days"];
        datesIndex_ = statement->columnMap()["dates"];
    }
    
    const int32_t idIndex() const {
        return idIndex_;
    }
    
    const int32_t nameIndex() const {
        return nameIndex_;
    }
    
    const int32_t daysIndex() const {
        return daysIndex_;
    }
    
    const int32_t datesIndex() const {
        return datesIndex_;
    }
    
private:
    int32_t idIndex_;
    int32_t nameIndex_;
    int32_t daysIndex_;
    int32_t datesIndex_;
};

class TransferMapping {
public:
    TransferMapping(Ref<Statement> statement) {
        sourceIdIndex_ = statement->columnMap()["sourceId"];
        destinationIdIndex_ = statement->columnMap()["destinationId"];
        durationIndex_ = statement->columnMap()["duration"];
    }
    
    const int32_t sourceIdIndex() const {
        return sourceIdIndex_;
    }
    
    const int32_t destinationIdIndex() const {
        return destinationIdIndex_;
    }
    
    const int32_t durationIndex() const {
        return durationIndex_;
    }
    
private:
    int32_t sourceIdIndex_;
    int32_t destinationIdIndex_;
    int32_t durationIndex_;
};

}

#endif /* TK_MAPPING_H */
