/*
 *  CSARouter.cpp
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#include "CSARouter.h"
#include "Trip.h"
#include "Mapping.h"
#include "Error.h"

using namespace tk;
using namespace tk::Router;

class ConnectionVectorCompare {
public:
    bool operator()(Connection& connection1, Connection& connection2) const {
        return connection1.startTime() < connection2.startTime();
    }
};

size_t IndexInfinity = std::numeric_limits<size_t>::max();

ErrorOr<void> CSA::load() {
    if (loaded_) {
        return {};
    }
    
    Status status = Status();
    StopTimeVector stopTimes(0);
    ConnectionVector connections(0);
    std::map<ItemID, Calendar> calendarByID;
    std::map<ItemID, Trip> tripsByID;
    
    Ref<Statement> fetchStmt;
    
    fetchStmt = makeRef<Statement>(db_, "SELECT id, calendarId, routeId FROM Trip");
    if (fetchStmt->prepare().isOK()) {
        TripMapping mapping = TripMapping(fetchStmt);
        
        while ((status = fetchStmt->next()).isRow()) {
            Trip trip = Trip((*fetchStmt)[mapping.idIndex()].int64Value(),
                             (*fetchStmt)[mapping.calendarIDIndex()].int64Value(),
                             (*fetchStmt)[mapping.routeIDIndex()].int64Value());
            
            tripsByID[(*fetchStmt)[mapping.idIndex()].int64Value()] = trip;
        }
        
        if (!status.isDone()) {
            return Error(db_->handle());
        }
    }
    
    fetchStmt->close();
    
    fetchStmt = makeRef<Statement>(db_, "SELECT id, arrivalTime, tripId, stopPlaceId FROM StopTime ORDER BY tripId");
    if (fetchStmt->prepare().isOK()) {
        StopTimeMapping mapping = StopTimeMapping(fetchStmt);
        
        Status status = Status();
        
        while ((status = fetchStmt->next()).isRow()) {
            StopTime stopTime = StopTime((*fetchStmt)[mapping.stopPlaceIDIndex()].int64Value(),
                                         (*fetchStmt)[mapping.tripIDIndex()].int64Value(),
                                         (*fetchStmt)[mapping.arrivalTimeIndex()].intValue());
            
            stopTimes.push_back(stopTime);
        }
        
        if (!status.isDone()) {
            return Error(db_->handle());
        }
    }
    
    fetchStmt->close();
    
    fetchStmt = makeRef<Statement>(db_, "SELECT id, days FROM Calendar");
    if (fetchStmt->prepare().isOK()) {
        CalendarMapping mapping = CalendarMapping(fetchStmt);
        
        while (fetchStmt->next().isRow()) {
            ItemID id = (*fetchStmt)[mapping.idIndex()].int64Value();
            uint8_t days = (*fetchStmt)[mapping.daysIndex()].int64Value();
            
            calendarByID[id] = Calendar(id, days);
        }
        
        if (!status.isDone()) {
            return Error(db_->handle());
        }
    }
    
    fetchStmt->close();
    
    for (size_t i = 0; i < stopTimes.size(); i++) {
        ItemID tripID = stopTimes[i].tripID();
        
        if (stopTimes[i].tripID() == stopTimes[i + 1].tripID()) {
            Connection connection = Connection(stopTimes[i].stopPlaceID(),
                                               stopTimes[i + 1].stopPlaceID(),
                                               stopTimes[i].time(),
                                               stopTimes[i + 1].time(),
                                               tripID,
                                               tripsByID[tripID].calendarID());
            
            connections.push_back(connection);
        }
    }
    
    std::sort(connections.begin(), connections.end(), ConnectionVectorCompare());
    
    connections_ = std::move(connections);
    calendarByID_ = std::move(calendarByID);
    tripsByID_ = std::move(tripsByID);
    
    loaded_ = true;
    return {};
}

ErrorOr<void> CSA::unload() {
    connections_.clear();
    calendarByID_.clear();
    db_ = nullptr;
    loaded_ = false;
    
    return {};
}

ErrorOr<TripPlan> CSA::query(ItemID source, ItemID destination, Date date) {
    ItineraryVector itineraries = ItineraryVector();
    Time departureTime = date.seconds();
    std::map<ItemID, Calendar> calendars;
    
    /* Fetch all the available Calendars at the specified date */
    for (auto &calendar: calendarByID_) {
        if (calendar.second.isAvailable(date)) {
            calendars[calendar.second.id()] = calendar.second;
        }
    }
    
    Time previousDeparture = departureTime;
    
    /*
     previousIndex is an optimization used to prevent iterating over
     the connections vector from the begining each time
     */
    size_t previousIndex = 0;
    
    for (size_t i = 0; i < connections_.size(); i++) {
        std::map<ItemID, Time> earliestArrival;
        std::map<ItemID, size_t> connectionIndex;
        
        earliestArrival[source] = previousDeparture;
        Time earliest = Time::Infinity();
        
        /* Look for the earliest departure */
        for (size_t i = previousIndex; i < connections_.size(); i++) {
            Connection connection = connections_[i];
            if (connection.startTime() >= previousDeparture) {
                previousIndex = i;
                break;
            }
        }
        
        for (size_t i = previousIndex; i < connections_.size(); i++) {
            Connection connection = connections_[i];
            Time startEarliest = Time::Infinity();
            Time endEarliest = Time::Infinity();
            
            if (earliestArrival.count(connection.startStopPlaceID())) {
                startEarliest = earliestArrival[connection.startStopPlaceID()];
            }
            
            if (earliestArrival.count(connection.endStopPlaceID())) {
                endEarliest = earliestArrival[connection.endStopPlaceID()];
            }
            
            if (connection.startTime() >= startEarliest
                && connection.endTime() < endEarliest
                && calendars.count(connection.calendarID()))
            {
                if (connection.endStopPlaceID() == destination && connection.endTime() < earliest) {
                    earliest = connection.endTime();
                } else if (earliest <= connection.startTime()) {
                    /* There is no better StopTime, so we break */
                    break;
                }
                
                earliestArrival[connection.endStopPlaceID()] = connection.endTime();
                connectionIndex[connection.endStopPlaceID()] = i;
            }
        }
        
        size_t previousConnectionIndex = IndexInfinity;
        if (connectionIndex.count(destination)) {
            previousConnectionIndex = connectionIndex[destination];
        } else {
            /* No departure were found for the destination StopPlace, so we break. */
            break;
        }
        
        ConnectionVector route = ConnectionVector();
        
        for (size_t i = 0; i < connectionIndex.size(); i++) {
            Connection connection = connections_[previousConnectionIndex];
            route.insert(route.begin(), connection);
            
            if (connectionIndex.count(connection.startStopPlaceID())) {
                previousConnectionIndex = connectionIndex[connection.startStopPlaceID()];
            } else {
                previousConnectionIndex = IndexInfinity;
                previousDeparture = Time(route.front().startTime().seconds() + 1);
                break;
            }
        }
        
        StopVector stops;
        RideVector rides;
        ItemID previousTripID = route.front().tripID();
        size_t routeSize = route.size();
        
        for (size_t i = 0; i < routeSize; i++) {
            Connection connection = route[i];
            
            /* The last StopTime in a trip */
            if (connection.tripID() != previousTripID) {
                Stop stop = Stop(route[i - 1].endStopPlaceID(),
                                 route[i - 1].tripID(),
                                 route[i - 1].endTime());
                
                stops.push_back(stop);
                previousTripID = connection.tripID();
                
                /* Create a Ride to hold the previous trip stops */
                ItemID routeID = tripsByID_[stops.front().tripID()].routeID();
                Ride ride = Ride(std::move(stops), routeID);
                rides.push_back(std::move(ride));
                
                /* Create a new StopVector to hold the next trip stops */
                stops = StopVector();
            }
            
            Stop stop = Stop(connection.startStopPlaceID(),
                             connection.tripID(),
                             connection.startTime());
            
            stops.push_back(stop);
            
            /* The last StopTime */
            if (i == routeSize - 1) {
                Stop stop = Stop(connection.endStopPlaceID(),
                                 connection.tripID(),
                                 connection.endTime());
                
                stops.push_back(stop);
                
                /* Create a Ride to hold the last trip stops */
                ItemID routeID = tripsByID_[stops.front().tripID()].routeID();
                Ride ride = Ride(std::move(stops), routeID);
                rides.push_back(std::move(ride));
            }
        }
        
        Ref<Itinerary> itinerary = makeRef<Itinerary>(rides);
        itineraries.push_back(itinerary);
    }
    
    return TripPlan(source, destination, date, itineraries);
}
