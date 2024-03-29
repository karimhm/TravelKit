# TravelKit Data Format

### Table of Contents
- [Overview](#overview)
- [Term definitions](#term-definitions)
- [Field Types](#field-types)
- [Tables](#tables)
    - [StopPlace](#stopplace)
    - [Localization](#localization)

## Overview
The **TravelKit Data Format (TKDF)** defines the SQL representation of public transportation data used by *TravelKit*. The format was inspired from [GTFS](https://developers.google.com/transit/gtfs). 

The data is encapsulated within an [SQLite](https://sqlite.org/about.html) database, the file extension is ***trdb***.

## Term definitions
* **Table**: A set of records sharing the same attributes.
* **Record**: A set of multiple fields representing a single item. 
* **Field**: Represents the property value of a single record.
* **Required**: The field value is mandatory and must be present.
* **Optional**: The field value is not mandatory and can be omitted.

## Field Types
* **ID**: A 64 bit unsigned integer that uniquely identifies a **Record**.
* **Integer**: A 64 bit signed integer.
* **Latitude**: The [WGS84](https://wikipedia.org/wiki/World_Geodetic_System) latitude in decimal degrees.
* **Longitude**: The [WGS84](https://wikipedia.org/wiki/World_Geodetic_System) longitude in decimal degrees.
* **Time**: A 64 bit unsigned integer represents the number of seconds since the begining of a single day.
* **Text**: A sequence of UTF-8 characters.
* **Text ID**: The identifier of a text record in the **Localization** table.
* **Language ID**: The IETF [BCP 47](http://www.rfc-editor.org/rfc/bcp/bcp47.txt) language code.

## Tables
### StopPlace
Table: **Required**

Defines a physical place where vehicles stop to allow passengers to enter or to leave.

| Field Name    | Type          | SQL Datatype      | Required | Description          |
|---------------|---------------|-------------------|----------|----------------------|
id | `ID` | `INTEGER` | **Required** | The unique identifier of the record
nameId | `Text ID` | `INTEGER` | **Required** | The name of the place
latitude | `Latitude` | `DOUBLE` | Optional | The latitude of the place
longitude | `Longitude` | `DOUBLE` | Optional | The longitude of the place

The SQL statement to create the table:
``` SQL
CREATE TABLE IF NOT EXISTS StopPlace (
    id INTEGER PRIMARY KEY NOT NULL,
    nameId INTEGER REFERENCES Localization(id) NOT NULL,
    latitude DOUBLE,
    longitude DOUBLE
);
```
---

### Calendar
Table: **Required**

Defines the service dates of trips.

| Field Name    | Type          | SQL Datatype      | Required | Description          |
|---------------|---------------|-------------------|----------|----------------------|
id | `ID` | `INTEGER` | **Required** | The unique identifier of the record
nameId | `Text ID` | `INTEGER` | Optional | The name of the calendar
shortNameId | `Text ID` | `INTEGER` | Optional | The short name of the calendar
days | `Integer` | `INTEGER` | **Required** | A bitset containing the operations days during the week. 1 means operational, 0 means not operational. The first bit represent  *Sunday*.

The SQL statement to create the table:
``` SQL
CREATE TABLE IF NOT EXISTS Calendar (
    id INTEGER PRIMARY KEY NOT NULL,
    nameId INTEGER REFERENCES Localization(id),
    shortNameId INTEGER REFERENCES Localization(id),
    days INT CHECK (days <= 127) NOT NULL
);
```
---

### StopTime
Table: **Required**

Defines a single stop of the vehicle during a trip at a physical place (*StopPlace*)

| Field Name    | Type          | SQL Datatype      | Required | Description          |
|---------------|---------------|-------------------|----------|----------------------|
id | `ID` | `INTEGER` | **Required** | The unique identifier of the record
stopPlaceId | `ID` | `INTEGER` | **Required** | The identifier of the  **StopPlace** where the vehicle stops
tripId | `ID` | `INTEGER` | **Required** | The dentifier of the **Trip** this stop time is belonging to
arrivalTime | `Time` | `INTEGER` | **Required** | Arrival time of a specific **Trip** at a single **StopPlace**
position | `Integer` | `INTEGER` | **Required** | The order of this stop time for a specific **Trip**, this value must be unique increasing along the **Trip**. 

The SQL statement to create the table:
``` SQL
CREATE TABLE IF NOT EXISTS StopTime (
    id INTEGER PRIMARY KEY NOT NULL,
    stopPlaceId INTEGER REFERENCES StopPlace(id) NOT NULL,
    tripId INTEGER REFERENCES Trip(id) NOT NULL,
    arrivalTime INT NOT NULL,
    position INT CHECK (position <= 65535) NOT NULL
);
```
---

### Localization
Table: **Required**

| Field Name    | Type          | SQL Datatype      | Required | Description          |
|---------------|---------------|-------------------|----------|----------------------|
id | `ID` | `INTEGER` | **Required** | The identifier of the record, its possible to have multiple records that sahre the same id but not the language id
language | `Language ID` | `INTEGER` | **Required** | The text language id
text | `Text` | `TEXT` | **Required** | The localized text

The SQL statement to create the table:
``` SQL
CREATE TABLE IF NOT EXISTS Localization (
    id INTEGER NOT NULL,
    language TEXT NOT NULL,
    text TEXT NOT NULL
);
```
