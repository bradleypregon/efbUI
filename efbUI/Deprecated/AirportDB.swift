// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let airportDB = try? newJSONDecoder().decode(AirportDB.self, from: jsonData)

import Foundation
/*
// MARK: - AirportDB
struct AirportDB: Codable {
    let ident: String?
    let type, name: String?
    let latitudeDeg, longitudeDeg: Double?
    let elevationFt, continent, isoCountry, isoRegion: String?
    let municipality, scheduledService: String?
    let gpsCode: String?
    let iataCode, localCode: String?
    let homeLink: String?
    let wikipediaLink: String?
    let keywords: String?
    let icaoCode: String?
    let runways: [Runway]?
    let freqs: [Freq]?
    let country, region: Country?
    let navaids: [Navaid]?
    let station: Station?

    enum CodingKeys: String, CodingKey {
        case ident, type, name
        case latitudeDeg = "latitude_deg"
        case longitudeDeg = "longitude_deg"
        case elevationFt = "elevation_ft"
        case continent
        case isoCountry = "iso_country"
        case isoRegion = "iso_region"
        case municipality
        case scheduledService = "scheduled_service"
        case gpsCode = "gps_code"
        case iataCode = "iata_code"
        case localCode = "local_code"
        case homeLink = "home_link"
        case wikipediaLink = "wikipedia_link"
        case keywords
        case icaoCode = "icao_code"
        case runways, freqs, country, region, navaids, station
    }
}

// MARK: - Country
struct Country: Codable {
    let id, code, name, continent: String?
    let wikipediaLink: String?
    let keywords, localCode, isoCountry: String?

    enum CodingKeys: String, CodingKey {
        case id, code, name, continent
        case wikipediaLink = "wikipedia_link"
        case keywords
        case localCode = "local_code"
        case isoCountry = "iso_country"
    }
}

// MARK: - Freq
struct Freq: Codable {
    let id, airportRef: String?
    let airportIdent: String?
    let type, freqDescription, frequencyMhz: String?

    enum CodingKeys: String, CodingKey {
        case id
        case airportRef = "airport_ref"
        case airportIdent = "airport_ident"
        case type
        case freqDescription = "description"
        case frequencyMhz = "frequency_mhz"
    }
}

// MARK: - Navaid
struct Navaid: Codable {
    let id, filename, ident, name: String?
    let type, frequencyKhz, latitudeDeg, longitudeDeg: String?
    let elevationFt, isoCountry, dmeFrequencyKhz, dmeChannel: String?
    let dmeLatitudeDeg, dmeLongitudeDeg, dmeElevationFt, slavedVariationDeg: String?
    let magneticVariationDeg, usageType, power: String?
    let associatedAirport: String?

    enum CodingKeys: String, CodingKey {
        case id, filename, ident, name, type
        case frequencyKhz = "frequency_khz"
        case latitudeDeg = "latitude_deg"
        case longitudeDeg = "longitude_deg"
        case elevationFt = "elevation_ft"
        case isoCountry = "iso_country"
        case dmeFrequencyKhz = "dme_frequency_khz"
        case dmeChannel = "dme_channel"
        case dmeLatitudeDeg = "dme_latitude_deg"
        case dmeLongitudeDeg = "dme_longitude_deg"
        case dmeElevationFt = "dme_elevation_ft"
        case slavedVariationDeg = "slaved_variation_deg"
        case magneticVariationDeg = "magnetic_variation_deg"
        case usageType, power
        case associatedAirport = "associated_airport"
    }
}

// MARK: - Runway
struct Runway: Codable {
    let id, airportRef: String?
    let airportIdent: String?
    let lengthFt, widthFt, surface, lighted: String?
    let closed, leIdent, leLatitudeDeg, leLongitudeDeg: String?
    let leElevationFt, leHeadingDegT, leDisplacedThresholdFt, heIdent: String?
    let heLatitudeDeg, heLongitudeDeg, heElevationFt, heHeadingDegT: String?
    let heDisplacedThresholdFt: String?
    let heIls, leIls: EIls?

    enum CodingKeys: String, CodingKey {
        case id
        case airportRef = "airport_ref"
        case airportIdent = "airport_ident"
        case lengthFt = "length_ft"
        case widthFt = "width_ft"
        case surface, lighted, closed
        case leIdent = "le_ident"
        case leLatitudeDeg = "le_latitude_deg"
        case leLongitudeDeg = "le_longitude_deg"
        case leElevationFt = "le_elevation_ft"
        case leHeadingDegT = "le_heading_degT"
        case leDisplacedThresholdFt = "le_displaced_threshold_ft"
        case heIdent = "he_ident"
        case heLatitudeDeg = "he_latitude_deg"
        case heLongitudeDeg = "he_longitude_deg"
        case heElevationFt = "he_elevation_ft"
        case heHeadingDegT = "he_heading_degT"
        case heDisplacedThresholdFt = "he_displaced_threshold_ft"
        case heIls = "he_ils"
        case leIls = "le_ils"
    }
}

// MARK: - EIls
struct EIls: Codable {
    let freq: Double?
    let course: Int?
}

// MARK: - Station
struct Station: Codable {
    let icaoCode: String?
    let distance: Double?

    enum CodingKeys: String, CodingKey {
        case icaoCode = "icao_code"
        case distance
    }
}
*/
