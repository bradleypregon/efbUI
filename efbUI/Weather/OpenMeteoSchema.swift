//
//  OpenMeteoSchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/10/24.
//

import Foundation

/*
 {
   "latitude": 52.52,
   "longitude": 13.419998,
   "generationtime_ms": 0.0519752502441406,
   "utc_offset_seconds": 7200,
   "timezone": "Europe/Berlin",
   "timezone_abbreviation": "CEST",
   "elevation": 38,
   "current_units": {
     "time": "unixtime",
     "interval": "seconds",
     "temperature_2m": "°F",
     "relative_humidity_2m": "%",
     "wind_speed_10m": "mp/h",
     "wind_direction_10m": "°",
     "wind_gusts_10m": "mp/h"
   },
   "current": {
     "time": 1728588600,
     "interval": 900,
     "temperature_2m": 53,
     "relative_humidity_2m": 72,
     "wind_speed_10m": 8.3,
     "wind_direction_10m": 289,
     "wind_gusts_10m": 23
   },
   "daily_units": {
     "time": "unixtime",
     "sunrise": "unixtime",
     "sunset": "unixtime"
   },
   "daily": {
     "time": [1728511200],
     "sunrise": [1728537844],
     "sunset": [1728577336]
   }
 }
 */

// MARK: - OpenMeteoSchema
struct OpenMeteoSchema: Codable {
  let latitude, longitude: Double
    let generationtimeMs: Float
    let utcOffsetSeconds: Int
    let timezone, timezoneAbbreviation: String
    let elevation: Int
    let currentUnits: CurrentUnits
    let current: Current
    let dailyUnits: DailyUnits
    let daily: Daily

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case currentUnits = "current_units"
        case current
        case dailyUnits = "daily_units"
        case daily
    }
}

// MARK: - Current
struct Current: Codable {
    let time, interval: Int
    let temperature2M, relativeHumidity2M: Float
    let windSpeed10M: Float
    let windDirection10M: Int
    let windGusts10M: Float

    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relative_humidity_2m"
        case windSpeed10M = "wind_speed_10m"
        case windDirection10M = "wind_direction_10m"
        case windGusts10M = "wind_gusts_10m"
    }
}

// MARK: - CurrentUnits
struct CurrentUnits: Codable {
    let time, interval, temperature2M, relativeHumidity2M: String
    let windSpeed10M, windDirection10M, windGusts10M: String

    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relative_humidity_2m"
        case windSpeed10M = "wind_speed_10m"
        case windDirection10M = "wind_direction_10m"
        case windGusts10M = "wind_gusts_10m"
    }
}

// MARK: - Daily
struct Daily: Codable {
    let time, sunrise, sunset: [Int]
}

// MARK: - DailyUnits
struct DailyUnits: Codable {
    let time, sunrise, sunset: String
}

