/* Hub */
CREATE TABLE IF NOT EXISTS Hub (
    id INTEGER PRIMARY KEY NOT NULL,
    latitude DOUBLE,
    longitude DOUBLE
);

/* StopPlace */
CREATE TABLE IF NOT EXISTS StopPlace (
    id INTEGER PRIMARY KEY NOT NULL,
    nameId INTEGER REFERENCES Localization(id) NOT NULL,
    latitude DOUBLE,
    longitude DOUBLE
);

/* StopTime */
CREATE TABLE IF NOT EXISTS StopTime (
    id INTEGER PRIMARY KEY NOT NULL,
    stopPlaceId INTEGER REFERENCES StopPlace(id) NOT NULL,
    tripId INTEGER REFERENCES Trip(id) NOT NULL,
	arrivalTime INT NOT NULL,
	position INT CHECK (position <= 65535) NOT NULL
);

/* Trip */
CREATE TABLE IF NOT EXISTS Trip (
    id INTEGER PRIMARY KEY NOT NULL,
    calendarId INTEGER REFERENCES Calendar(id) NOT NULL,
    routeId INTEGER REFERENCES Route(id) NOT NULL,
	direction INT CHECK (direction = 1 OR direction = 2), /* Outbound = 1, Inbound = 2 */
    headsignId INTEGER REFERENCES Localization(id),
    vehicleId INTEGER REFERENCES Vehicle(id)
);

/* TripAttribute */
CREATE TABLE IF NOT EXISTS TripAttribute (
    id INTEGER PRIMARY KEY NOT NULL,
    wheelchairAccessible INT,
    bikesAllowed INT,
    airConditioning INT,
    wifi INT,
    powerPlug Int,
    dining INT,
    sleeping INT
);

/* Route */
CREATE TABLE IF NOT EXISTS Route (
    id INTEGER PRIMARY KEY NOT NULL,
    nameId INTEGER REFERENCES Localization(id),
    inboundNameId INTEGER REFERENCES Localization(id),
    descriptionId INTEGER REFERENCES Localization(id),
    operatorId INTEGER REFERENCES Operator(id),
    pathId INTEGER REFERENCES Path(id),
    color INT
);

/* RoutePattern */
CREATE TABLE IF NOT EXISTS RoutePattern (
    id INTEGER PRIMARY KEY NOT NULL,
    routeId INTEGER REFERENCES Route(id) NOT NULL,
    stopPlaceId INTEGER REFERENCES StopPlace(id) NOT NULL,
    direction INT CHECK (direction = 1 OR direction = 2), /* Outbound = 1, Inbound = 2 */
	position INT CHECK (position <= 65535) NOT NULL
);

-- 1 | 2  | 80   -
-- 1 | 3  | 80   -
-- 1 | 4  | 80   -
-- 2 | 5  | 80   -

-- 2 | 92 | 240  =
-- 2 | 22 | 240  =

-- 2 | 33 | 250  *

-------------------------------

-- N | N  | 80
-- 2 | N  | 240
-- 2 | 33 |250

/* Fare */
CREATE TABLE IF NOT EXISTS Fare (
    id INTEGER PRIMARY KEY,
    nameId INTEGER REFERENCES Localization(id),
    routeId INTEGER REFERENCES Route(id),
    tripId INTEGER REFERENCES Trip(id),
    sourceId INTEGER REFERENCES StopPlace(id) NOT NULL,
    destinationId INTEGER REFERENCES StopPlace(id) NOT NULL,
    currency TEXT NOT NULL,
    price NUMERIC NOT NULL,
    isBidirectional INT
);

/* Path */
CREATE TABLE IF NOT EXISTS Path (
    id INTEGER PRIMARY KEY NOT NULL
);

/* SubPath */
CREATE TABLE IF NOT EXISTS SubPath (
    id INTEGER PRIMARY KEY NOT NULL,
    pathId INTEGER REFERENCES Path(id) NOT NULL,
    sourceId INTEGER REFERENCES StopPlace(id) NOT NULL,
    destinationId INTEGER REFERENCES StopPlace(id) NOT NULL,
    position INTEGER NOT NULL, /* |-From-|-To-| |-To-|-From-| */
    points BLOB NOT NULL
);

/* PathPoint */
CREATE TABLE IF NOT EXISTS PathPoint (
    id INTEGER PRIMARY KEY NOT NULL,
    subPathId INTEGER REFERENCES SubPath(id) NOT NULL,
    latitude DOUBLE INTEGER NOT NULL,
    longitude DOUBLE INTEGER NOT NULL,
    position INTEGER NOT NULL
);

/* Transfer */
CREATE TABLE IF NOT EXISTS Transfer (
    id INTEGER PRIMARY KEY NOT NULL,
    sourceId INTEGER REFERENCES StopPlace(id) NOT NULL,
    destinationId INTEGER REFERENCES StopPlace(id) NOT NULL,
    type INT NOT NULL (type = 1 OR type = 2), /* Switch = 1, Walk = 2 */
    duration INT NOT NULL,
    distance DOUBLE
);

/* Calendar */
CREATE TABLE IF NOT EXISTS Calendar (
    id INTEGER PRIMARY KEY NOT NULL,
    nameId INTEGER REFERENCES Localization(id),
    shortNameId INTEGER REFERENCES Localization(id),
    days INT CHECK (days <= 127) NOT NULL
);

/* CalendarDate */
CREATE TABLE IF NOT EXISTS CalendarDate (
    id INTEGER PRIMARY KEY NOT NULL,
    calendarId INTEGER REFERENCES Calendar(id) NOT NULL,
    exceptionType INT CHECK (exceptionType = 1 OR exceptionType = 2) NOT NULL, /* Add = 1, Remove = 2 */
    date INT NOT NULL
);

/* Operator */
CREATE TABLE Operator (
    id INTEGER PRIMARY KEY NOT NULL,
    timezone TEXT,
    nameId INTEGER REFERENCES Localization(id),
    urlId INTEGER REFERENCES Localization(id),
    emailId INTEGER REFERENCES Localization(id),
	phoneId INTEGER REFERENCES Localization(id)
);

/* Vehicle */
CREATE TABLE IF NOT EXISTS Vehicle (
    id INTEGER PRIMARY KEY NOT NULL,
    nameId INTEGER REFERENCES Localization(id),
    descriptionId INTEGER REFERENCES Localization(id),
    energyType INT,
    wheelchairAccessible INT,
    bikesAllowed INT,
    airConditioning INT,
    wifiAvailability INT,
    powerPlugs Int,
    diningAvailability INT,
    hygiene INT
);

/* City */
CREATE TABLE IF NOT EXISTS City (
    id INTEGER PRIMARY KEY NOT NULL,
    nameId INTEGER REFERENCES Localization(id) NOT NULL
);

/* Localization */
CREATE TABLE IF NOT EXISTS Localization (
    id INTEGER NOT NULL,
    language TEXT NOT NULL,
    text TEXT NOT NULL
);

/* Properties */
CREATE TABLE IF NOT EXISTS Properties (
    id TEXT PRIMARY KEY UNIQUE, 
    value BLOB
);

/* 
last_compatible_version
1.0

language
en

uuid
4620EF50-583C-4A5B-A0FD-FE9F19E0405D

timestamp
1549631769

timezone
Algiers/Africa
*/

/*************************************************
 *                    Queries                    *
 *************************************************/

/* Select a stop place by id */
SELECT 
    StopPlace.id, 
    StopPlace.latitude, 
    StopPlace.longitude, 
    Localization.text AS name
FROM 
    StopPlace 
JOIN 
    Localization ON StopPlace.nameId = Localization.id 
AND 
    StopPlace.id = :id
AND 
    Localization.language = :language

/* Select a fare */
SELECT 
    currency, 
    price 
FROM 
    Fare 
WHERE 
    routeId = :routeId OR routeId = NULL
AND 
    tripId = :tripId OR tripId = NULL
AND 
    sourceId = :sourceId 
AND 
    destinationId = :destinationId