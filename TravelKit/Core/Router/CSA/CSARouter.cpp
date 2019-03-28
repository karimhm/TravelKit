/*
 *  CSARouter.cpp
 *
 *  Copyright (C) 2019 Karim. All rights reserved.
 */

#include "CSARouter.h"
#include "Trip.h"
#include "Mapping.h"
#include "Error.h"
#include "QueryRoute.h"
#include "OmitSameTripArrival.h"

using namespace tk;
using namespace tk::Router;

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
            stopTimes.push_back({
                static_cast<ItemID>((*fetchStmt)[mapping.stopPlaceIDIndex()].int64Value()),
                static_cast<ItemID>((*fetchStmt)[mapping.tripIDIndex()].int64Value()),
                (*fetchStmt)[mapping.arrivalTimeIndex()].intValue()
            });
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
            connections.push_back({stopTimes[i].stopPlaceID(),
                stopTimes[i + 1].stopPlaceID(),
                stopTimes[i].time(),
                stopTimes[i + 1].time(),
                tripID,
                tripsByID[tripID].calendarID()});
        }
    }
    
    std::sort(connections.begin(), connections.end(), Connection::Compare());
    
    connections_ = std::move(connections);
    calendarByID_ = std::move(calendarByID);
    tripsByID_ = std::move(tripsByID);
    
    loaded_ = true;
    return {};
}

ErrorOr<void> CSA::unload() {
    connections_.clear();
    calendarByID_.clear();
    tripsByID_.clear();
    loaded_ = false;
    
    return {};
}

ErrorOr<TripPlan> CSA::query(ItemID source, ItemID destination, Date date, QueryOptions options) {
    std::vector<QueryRoute> routes = std::vector<QueryRoute>();
    Time departureTime = date.seconds();
    std::map<ItemID, Calendar> calendars;
    
    // Fetch all the available Calendars for the given date
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
    
    // Query loop
    for (size_t i = 0; i < connections_.size(); i++) {
        std::map<ItemID, Time> earliestArrival;
        std::map<ItemID, size_t> connectionIndex;
        
        earliestArrival[source] = previousDeparture;
        Time earliest = Time::Infinity();
        
        // Look for the earliest departure */
        for (size_t i = previousIndex; i < connections_.size(); i++) {
            const Connection& connection = connections_[i];
            if (connection.startTime() >= previousDeparture) {
                previousIndex = i;
                break;
            }
        }
        
        for (size_t i = previousIndex; i < connections_.size(); i++) {
            const Connection& connection = connections_[i];
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
                    // There is no better StopTime, so we break
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
            // No departure were found for the destination StopPlace, so we break
            break;
        }
        
        ConnectionVector route = ConnectionVector();
        size_t transfers = 0;
        ItemID previousTrip = connections_[previousConnectionIndex].tripID();
        
        for (size_t i = 0; i < connectionIndex.size(); i++) {
            const Connection& connection = connections_[previousConnectionIndex];
            route.insert(route.begin(), connection);
            
            if (connection.tripID() != previousTrip) {
                transfers++;
                previousTrip = connection.tripID();
            }
            
            if (connectionIndex.count(connection.startStopPlaceID())) {
                previousConnectionIndex = connectionIndex[connection.startStopPlaceID()];
            } else {
                previousDeparture = Time(route.front().startTime().seconds() + 1);
                break;
            }
        }
        
        ItemID id = IID(static_cast<uint16_t>(routes.size())).rawID();
        routes.push_back({id, std::move(route), transfers});
    } // Query loop
    
    // Filters
    if (options.omitSameTripArrival()) {
        Filter::OmitSameTripArrival::apply(routes);
    }
    
    // Construct itineraries
    ItineraryVector itineraries = ItineraryVector();
    
    for (const auto& route: routes) {
        StopVector stops;
        RideVector rides;
        const ConnectionVector& connections = route.connections();
        
        ItemID previousTripID = connections.front().tripID();
        const size_t routeSize = connections.size();
        
        for (size_t i = 0; i < routeSize; i++) {
            const Connection& connection = connections[i];
            
            // The last StopTime in a trip
            if (connection.tripID() != previousTripID) {
                stops.push_back({connections[i - 1].endStopPlaceID(),
                                 connections[i - 1].tripID(),
                                 connections[i - 1].endTime()});
                
                previousTripID = connection.tripID();
                
                // Create a Ride to hold the previous trip stops
                const ItemID routeID = tripsByID_[stops.front().tripID()].routeID();
                const ItemID tripID = stops.front().tripID();
                rides.push_back({std::move(stops), routeID, tripID});
                
                // Create a new StopVector to hold the next trip stops
                stops = StopVector();
            }
            
            stops.push_back({connection.startStopPlaceID(),
                             connection.tripID(),
                             connection.startTime()});
            
            // The last StopTime
            if (i == routeSize - 1) {
                stops.push_back({connection.endStopPlaceID(),
                                 connection.tripID(),
                                 connection.endTime()});
                
                // Create a Ride to hold the last trip stops
                ItemID routeID = tripsByID_[stops.front().tripID()].routeID();
                ItemID tripID = stops.front().tripID();
                rides.push_back({std::move(stops), routeID, tripID});
            }
        }
        
        itineraries.push_back({std::move(rides)});
    }
    
    return TripPlan(source, destination, date, std::move(itineraries));
}
