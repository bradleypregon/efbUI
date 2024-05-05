//
//  OSMWeatherSchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/16/23.
//

import Foundation

// MARK: - WeatherInfo
struct OSMWeatherSchema: Decodable {
  let lat, lon: Double
  let current: Current
  let daily: [Daily]
  
  enum CodingKeys: String, CodingKey {
    case lat, lon
    case current, daily
  }
}

struct Current: Decodable {
  let dt: Int
  let sunrise, sunset: Int
  let temp, feelsLike: Double
  let pressure, humidity: Int
  let dewPoint, uvi: Double
  let clouds, visibility: Int?
  let windSpeed: Double?
  let windDeg: Int?
  let windGust: Double?
  let weather: [Weather]
  let pop: Double?
  let rain: Rain?
  
  enum CodingKeys: String, CodingKey {
    case dt, sunrise, sunset, temp
    case feelsLike = "feels_like"
    case pressure, humidity
    case dewPoint = "dew_point"
    case uvi, clouds, visibility
    case windSpeed = "wind_speed"
    case windDeg = "wind_deg"
    case windGust = "wind_gust"
    case weather, pop, rain
  }
}

struct Rain: Decodable {
  let the1H: Double
  
  enum CodingKeys: String, CodingKey {
    case the1H = "1h"
  }
}

struct Weather: Decodable {
  let id: Int
  let main: String
  let description: String
  let icon: String
}

struct Daily: Decodable {
  let dt, sunrise, sunset, moonrise: Int
  let moonset: Int
  let moonPhase: Double
  let temp: Temp
  let feelsLike: FeelsLike
  let pressure, humidity: Int
  let dewPoint, windSpeed: Double
  let windDeg: Int
  let windGust: Double
  let weather: [Weather]
  let clouds: Int
  let pop: Double
  let rain: Double?
  let uvi: Double
  
  enum CodingKeys: String, CodingKey {
    case dt, sunrise, sunset, moonrise, moonset
    case moonPhase = "moon_phase"
    case temp
    case feelsLike = "feels_like"
    case pressure, humidity
    case dewPoint = "dew_point"
    case windSpeed = "wind_speed"
    case windDeg = "wind_deg"
    case windGust = "wind_gust"
    case weather, clouds, pop, rain, uvi
  }
}

struct FeelsLike: Decodable {
  let day, night, eve, morn: Double
}

struct Temp: Decodable {
  let day, min, max, night: Double
  let eve, morn: Double
}
