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
* **Latitude**: The [WGS84](https://wikipedia.org/wiki/World_Geodetic_System) latitude in decimal degrees.
* **Longitude**: The [WGS84](https://wikipedia.org/wiki/World_Geodetic_System) longitude in decimal degrees.
* **Text**: A sequence of UTF-8 characters.
* **Text ID**: The identifier of a text record in the **Localization** table.
* **Language ID**: The IETF [BCP 47](http://www.rfc-editor.org/rfc/bcp/bcp47.txt) language code.

## Tables
### StopPlace
Table: **Required**

Defines a physical place where vehicles stop to allow passengers to enter or to leave.

| Field Name    | Type          | SQL Datatype      | Required | Description          |
|---------------|---------------|-------------------|----------|----------------------|
id | `ID` | `INTEGER` | **Required**| The unique identifier of the record
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

### Localization
Table: **Required**

| Field Name    | Type          | SQL Datatype      | Required | Description          |
|---------------|---------------|-------------------|----------|----------------------|
id | `ID` | `INTEGER` | **Required** | The identifier of the record, its possible to have multiple records that sahre the same id but not the language id
language | `Language ID` | `INTEGER` | **Required**| The text language id
text | `Text` | `TEXT` | **Required** | The localized text

The SQL statement to create the table:
``` SQL
CREATE TABLE IF NOT EXISTS Localization (
    id INTEGER NOT NULL,
    language TEXT NOT NULL,
    text TEXT NOT NULL
);
```
