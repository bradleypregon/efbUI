//
//  OSMWeatherSchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/16/23.
//

import Foundation

// MARK: - WeatherInfo
struct OSMWeatherSchema: Codable {
  let lat, lon: Double
  let timezone: String
  let timezoneOffset: Int
  let current: Current
  let minutely: [Minutely]
  let hourly: [Current]
  let daily: [Daily]
  
  enum CodingKeys: String, CodingKey {
    case lat, lon, timezone
    case timezoneOffset = "timezone_offset"
    case current, minutely, hourly, daily
  }
}

// MARK: - Current
struct Current: Codable {
  let dt: Int
  let sunrise, sunset: Int?
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

// MARK: - Rain
struct Rain: Codable {
  let the1H: Double
  
  enum CodingKeys: String, CodingKey {
    case the1H = "1h"
  }
}

// MARK: - Weather
struct Weather: Codable {
  let id: Int
  let main: String
  let description: String
  let icon: String
}

//enum Description: String, Codable {
//    case brokenClouds = "broken clouds"
//    case clearSky = "clear sky"
//    case fewClouds = "few clouds"
//    case lightRain = "light rain"
//    case moderateRain = "moderate rain"
//    case scatteredClouds = "scattered clouds"
//}

//enum Main: String, Codable {
//  case clear = "Clear"
//  case clouds = "Clouds"
//  case rain = "Rain"
//}

// MARK: - Daily
struct Daily: Codable {
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

// MARK: - FeelsLike
struct FeelsLike: Codable {
  let day, night, eve, morn: Double
}

// MARK: - Temp
struct Temp: Codable {
  let day, min, max, night: Double
  let eve, morn: Double
}

// MARK: - Minutely
struct Minutely: Codable {
  let dt: Int
  let precipitation: Double
}
