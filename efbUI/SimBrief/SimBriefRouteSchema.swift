//
//  SimBriefRouteSchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/15/24.
//

import Foundation
//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Ofp
struct SimBriefOFP: Codable, Hashable {
  let fetch: SBFetch
  let params: SBParams
  let general: SBGeneral
  let origin: SBOrigin
  let destination: SBDestination
  let alternate: SBAlternate
  let takeoffAltn, enrouteAltn, navlog, etops: String
  let atc: SBATC
  let aircraft: SBAircraft
  let fuel: [String: Int]
  let fuelExtra: SBFuelExtra
  let times: [String: Int]
  let weights: SBWeights
  let impacts: SBImpacts
  let crew: SBCrew
  let notams: String
  let weather: SBWeather
  let sigmets: String
  let text: SBText
  let tracks: String
  let databaseUpdates: SBDatabaseUpdates
  let files, fmsDownloads: SBFiles
  let images: SBImages
  let links: String
  
  
  enum CodingKeys: String, CodingKey {
    case fetch, params, general, origin, destination, alternate
    case takeoffAltn = "takeoff_altn"
    case enrouteAltn = "enroute_altn"
    case navlog, etops, atc, aircraft, fuel
    case fuelExtra = "fuel_extra"
    case times, weights, impacts, crew, notams, weather, sigmets, text, tracks
    case databaseUpdates = "database_updates"
    case files
    case fmsDownloads = "fms_downloads"
    case images, links
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Aircraft
struct SBAircraft: Codable, Hashable {
  let icaocode, iatacode, baseType, icaoCode: String
  let iataCode, name, reg: String
  let fin: Int
  let selcal, equip: String
  let fuelfact, fuelfactor, maxPassengers: Int
  let internalId: String
  let isCustom: Int
  
  enum CodingKeys: String, CodingKey {
    case icaocode, iatacode
    case baseType = "base_type"
    case icaoCode = "icao_code"
    case iataCode = "iata_code"
    case name, reg, fin, selcal, equip, fuelfact, fuelfactor
    case maxPassengers = "max_passengers"
    case internalId = "internal_id"
    case isCustom = "is_custom"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Alternate
struct SBAlternate: Codable, Hashable {
  let icaoCode, iataCode, faaCode: String
  let elevation: Int
  let posLat, posLong: Double
  let name: String
  let timezone: Int
  let planRwy: String
  let transAlt, transLevel, cruiseAltitude, distance: Int
  let gcDistance, airDistance, trackTrue, trackMag: Int
  let tas, gs: Int
  let avgWindComp: String
  let avgWindDir, avgWindSpd, avgTropopause: Int
  let avgTdv: String
  let ete, burn: Int
  let route, routeIfps, metar: String
  let metarTime: String
  let metarCategory: String
  let metarVisibility, metarCeiling: Int
  let taf: String
  let tafTime: String
  let atis: [SBATIS]
  let notam: String
  
  enum CodingKeys: String, CodingKey {
    case icaoCode = "icao_code"
    case iataCode = "iata_code"
    case faaCode = "faa_code"
    case elevation
    case posLat = "pos_lat"
    case posLong = "pos_long"
    case name, timezone
    case planRwy = "plan_rwy"
    case transAlt = "trans_alt"
    case transLevel = "trans_level"
    case cruiseAltitude = "cruise_altitude"
    case distance
    case gcDistance = "gc_distance"
    case airDistance = "air_distance"
    case trackTrue = "track_true"
    case trackMag = "track_mag"
    case tas, gs
    case avgWindComp = "avg_wind_comp"
    case avgWindDir = "avg_wind_dir"
    case avgWindSpd = "avg_wind_spd"
    case avgTropopause = "avg_tropopause"
    case avgTdv = "avg_tdv"
    case ete, burn, route
    case routeIfps = "route_ifps"
    case metar
    case metarTime = "metar_time"
    case metarCategory = "metar_category"
    case metarVisibility = "metar_visibility"
    case metarCeiling = "metar_ceiling"
    case taf
    case tafTime = "taf_time"
    case atis, notam
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Ati
struct SBATIS: Codable, Hashable {
  let network: String
  let issued: String
  let letter, phonetic, type, message: String
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Atc
struct SBATC: Codable, Hashable {
  let flightplanText, route, routeIfps, callsign: String
  let initialSpd: Int
  let initialSpdUnit: String
  let initialAlt: Int
  let initialAltUnit, section18, firOrig, firDest: String
  let firAltn, firEtops, firEnroute: String
  
  enum CodingKeys: String, CodingKey {
    case flightplanText = "flightplan_text"
    case route
    case routeIfps = "route_ifps"
    case callsign
    case initialSpd = "initial_spd"
    case initialSpdUnit = "initial_spd_unit"
    case initialAlt = "initial_alt"
    case initialAltUnit = "initial_alt_unit"
    case section18
    case firOrig = "fir_orig"
    case firDest = "fir_dest"
    case firAltn = "fir_altn"
    case firEtops = "fir_etops"
    case firEnroute = "fir_enroute"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Crew
struct SBCrew: Codable, Hashable {
  let pilotId: Int
  let cpt, fo, dx, pu: String
  let fa: [String]
  
  enum CodingKeys: String, CodingKey {
    case pilotId = "pilot_id"
    case cpt, fo, dx, pu, fa
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - DatabaseUpdates
struct SBDatabaseUpdates: Codable, Hashable {
  let metarTaf, winds, sigwx, sigmet: Int
  let notams, tracks: Int
  
  enum CodingKeys: String, CodingKey {
    case metarTaf = "metar_taf"
    case winds, sigwx, sigmet, notams, tracks
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Destination
struct SBDestination: Codable, Hashable {
  let icaoCode, iataCode, faaCode: String
  let elevation: Int
  let posLat, posLong: Double
  let name: String
  let timezone: Int
  let planRwy: String
  let transAlt, transLevel: Int
  let metar: String
  let metarTime: String
  let metarCategory: String
  let metarVisibility, metarCeiling: Int
  let taf: String
  let tafTime: String
  let atis: [SBATIS]
  let notam: String
  
  enum CodingKeys: String, CodingKey {
    case icaoCode = "icao_code"
    case iataCode = "iata_code"
    case faaCode = "faa_code"
    case elevation
    case posLat = "pos_lat"
    case posLong = "pos_long"
    case name, timezone
    case planRwy = "plan_rwy"
    case transAlt = "trans_alt"
    case transLevel = "trans_level"
    case metar
    case metarTime = "metar_time"
    case metarCategory = "metar_category"
    case metarVisibility = "metar_visibility"
    case metarCeiling = "metar_ceiling"
    case taf
    case tafTime = "taf_time"
    case atis, notam
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Fetch
struct SBFetch: Codable, Hashable {
  let userid: Int
  let staticId, status: String
  let time: Double
  
  enum CodingKeys: String, CodingKey {
    case userid
    case staticId = "static_id"
    case status, time
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Files
struct SBFiles: Codable, Hashable {
  let directory: String
  let pdf: SBPDF
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - PDF
struct SBPDF: Codable, Hashable {
  let name, link: String
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - FuelExtra
struct SBFuelExtra: Codable, Hashable {
  let bucket: [SBBucket]
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Bucket
struct SBBucket: Codable, Hashable {
  let label: String
  let fuel, time: Int
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - General
struct SBGeneral: Codable, Hashable {
  let release: Int
  let icaoAirline: String
  let flightNumber, isEtops: Int
  let dxRmk, sysRmk: String
  let isDetailedProfile: Int
  let cruiseProfile, climbProfile, descentProfile, alternateProfile: String
  let reserveProfile: String
  let costindex: Int
  let contRule: String
  let initialAltitude: Int
  let stepclimbString: String
  let avgTempDev, avgTropopause, avgWindComp, avgWindDir: Int
  let avgWindSpd, gcDistance, routeDistance, airDistance: Int
  let totalBurn, cruiseTas: Int
  let cruiseMach: Double
  let passengers: Int
  let route, routeIfps, routeNavigraph: String
  
  enum CodingKeys: String, CodingKey {
    case release
    case icaoAirline = "icao_airline"
    case flightNumber = "flight_number"
    case isEtops = "is_etops"
    case dxRmk = "dx_rmk"
    case sysRmk = "sys_rmk"
    case isDetailedProfile = "is_detailed_profile"
    case cruiseProfile = "cruise_profile"
    case climbProfile = "climb_profile"
    case descentProfile = "descent_profile"
    case alternateProfile = "alternate_profile"
    case reserveProfile = "reserve_profile"
    case costindex
    case contRule = "cont_rule"
    case initialAltitude = "initial_altitude"
    case stepclimbString = "stepclimb_string"
    case avgTempDev = "avg_temp_dev"
    case avgTropopause = "avg_tropopause"
    case avgWindComp = "avg_wind_comp"
    case avgWindDir = "avg_wind_dir"
    case avgWindSpd = "avg_wind_spd"
    case gcDistance = "gc_distance"
    case routeDistance = "route_distance"
    case airDistance = "air_distance"
    case totalBurn = "total_burn"
    case cruiseTas = "cruise_tas"
    case cruiseMach = "cruise_mach"
    case passengers, route
    case routeIfps = "route_ifps"
    case routeNavigraph = "route_navigraph"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Images
struct SBImages: Codable, Hashable {
  let directory: String
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Impacts
struct SBImpacts: Codable, Hashable {
  let minus6000Ft, minus4000Ft, minus2000Ft, plus2000Ft: String
  let plus4000Ft, plus6000Ft, higherCi, lowerCi: String
  let zfwPlus1000, zfwMinus1000: String
  
  enum CodingKeys: String, CodingKey {
    case minus6000Ft = "minus_6000ft"
    case minus4000Ft = "minus_4000ft"
    case minus2000Ft = "minus_2000ft"
    case plus2000Ft = "plus_2000ft"
    case plus4000Ft = "plus_4000ft"
    case plus6000Ft = "plus_6000ft"
    case higherCi = "higher_ci"
    case lowerCi = "lower_ci"
    case zfwPlus1000 = "zfw_plus_1000"
    case zfwMinus1000 = "zfw_minus_1000"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Origin
struct SBOrigin: Codable, Hashable {
  let icaoCode, iataCode, faaCode: String
  let elevation: Int
  let posLat, posLong: Double
  let name: String
  let timezone, planRwy, transAlt, transLevel: Int
  let metar: String
  let metarTime: String
  let metarCategory: String
  let metarVisibility, metarCeiling: Int
  let taf: String
  let tafTime: String
  let atis, notam: String
  
  enum CodingKeys: String, CodingKey {
    case icaoCode = "icao_code"
    case iataCode = "iata_code"
    case faaCode = "faa_code"
    case elevation
    case posLat = "pos_lat"
    case posLong = "pos_long"
    case name, timezone
    case planRwy = "plan_rwy"
    case transAlt = "trans_alt"
    case transLevel = "trans_level"
    case metar
    case metarTime = "metar_time"
    case metarCategory = "metar_category"
    case metarVisibility = "metar_visibility"
    case metarCeiling = "metar_ceiling"
    case taf
    case tafTime = "taf_time"
    case atis, notam
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Params
struct SBParams: Codable, Hashable {
  let requestId, userId, timeGenerated: Int
  let staticId: String
  let xmlFile: String
  let ofpLayout: String
  let airac: Int
  let units: String
  
  enum CodingKeys: String, CodingKey {
    case requestId = "request_id"
    case userId = "user_id"
    case timeGenerated = "time_generated"
    case staticId = "static_id"
    case xmlFile = "xml_file"
    case ofpLayout = "ofp_layout"
    case airac, units
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Prefile
struct SBPrefile: Codable, Hashable {
  let vatsim: SBVatsim
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Vatsim
struct SBVatsim: Codable, Hashable {
  let name, site: String
  let link: String
  let form: SBVatsimForm
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - VatsimForm
struct SBVatsimForm: Codable, Hashable {
  let form: SBPurpleForm
  let ivao: SBIVAO
  let vatsimPrefile: SBVatsimPrefile
  
  enum CodingKeys: String, CodingKey {
    case form, ivao
    case vatsimPrefile = "vatsim_prefile"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - PurpleForm
struct SBPurpleForm: Codable, Hashable {
  let button: String
  let input: SBInput
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Input
struct SBInput: Codable, Hashable {
  let input: String
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Ivao
struct SBIVAO: Codable, Hashable {
  let name, site: String
  let link: String
  let form: SBIVAOForm
  let pilotedge, poscon: SBPilotEdge
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - IvaoForm
struct SBIVAOForm: Codable, Hashable {
  let form: SBIVAOPrefileForm
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - IvaoPrefileForm
struct SBIVAOPrefileForm: Codable, Hashable {
  let button, input: String
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Pilotedge
struct SBPilotEdge: Codable, Hashable {
  let name, site: String
  let link: String
  let form: String
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - VatsimPrefile
struct SBVatsimPrefile: Codable, Hashable {
  let form: SBVatsimPrefileForm
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - VatsimPrefileForm
struct SBVatsimPrefileForm: Codable, Hashable {
  let button: String
  let input: SBInput
  let ivaoPrefile: SBIVAOPrefile
  
  enum CodingKeys: String, CodingKey {
    case button, input
    case ivaoPrefile = "ivao_prefile"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - IvaoPrefile
struct SBIVAOPrefile: Codable, Hashable {
  let form: SBIVAOPrefileForm
  let pilotedgePrefile, posconPrefile: String
  let mapData: String
  let apiParams: SBAPIParams
  
  enum CodingKeys: String, CodingKey {
    case form
    case pilotedgePrefile = "pilotedge_prefile"
    case posconPrefile = "poscon_prefile"
    case mapData = "map_data"
    case apiParams = "api_params"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - APIParams
struct SBAPIParams: Codable, Hashable {
  let airline: String
  let fltnum: Int
  let type, orig, dest: String
  let date, dephour, depmin: Int
  let route: String
  let stehour, stemin: Int
  let reg: String
  let fin: Int
  let selcal, pax, altn, fl: String
  let cpt: String
  let pid, fuelfactor: Int
  let manualpayload, manualzfw: String
  let taxifuel, minfob: Int
  let minfobUnits: String
  let minfod: Int
  let minfodUnits: String
  let melfuel: Int
  let melfuelUnits: String
  let atcfuel: Int
  let atcfuelUnits: String
  let wxxfuel: Int
  let wxxfuelUnits: String
  let addedfuel: Int
  let addedfuelUnits, addedfuelLabel: String
  let tankering: Int
  let tankeringUnits, flightrules, flighttype, contpct: String
  let resvrule: String
  let taxiout, taxiin, cargo, origrwy: Int
  let destrwy, climb, descent, cruisemode: String
  let cruisesub, planformat: String
  let pounds, navlog, etops, stepclimbs: Int
  let tlr, notamsOpt, firnot, maps: Int
  let turntoflt, turntoapt, turntotime, turnfrflt: String
  let turnfrapt, turnfrtime, fuelstats, contlabel: String
  let staticId, acdata, acdataParsed: String
  
  enum CodingKeys: String, CodingKey {
    case airline, fltnum, type, orig, dest, date, dephour, depmin, route, stehour, stemin, reg, fin, selcal, pax, altn, fl, cpt, pid, fuelfactor, manualpayload, manualzfw, taxifuel, minfob
    case minfobUnits = "minfob_units"
    case minfod
    case minfodUnits = "minfod_units"
    case melfuel
    case melfuelUnits = "melfuel_units"
    case atcfuel
    case atcfuelUnits = "atcfuel_units"
    case wxxfuel
    case wxxfuelUnits = "wxxfuel_units"
    case addedfuel
    case addedfuelUnits = "addedfuel_units"
    case addedfuelLabel = "addedfuel_label"
    case tankering
    case tankeringUnits = "tankering_units"
    case flightrules, flighttype, contpct, resvrule, taxiout, taxiin, cargo, origrwy, destrwy, climb, descent, cruisemode, cruisesub, planformat, pounds, navlog, etops, stepclimbs, tlr
    case notamsOpt = "notams_opt"
    case firnot, maps, turntoflt, turntoapt, turntotime, turnfrflt, turnfrapt, turnfrtime, fuelstats, contlabel
    case staticId = "static_id"
    case acdata
    case acdataParsed = "acdata_parsed"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Text
struct SBText: Codable, Hashable {
  let natTracks: String
  let planHtml: String
  
  enum CodingKeys: String, CodingKey {
    case natTracks = "nat_tracks"
    case planHtml = "plan_html"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - PlanHtml - Changed -> REVIEW
//struct SBPlanHTML: Codable, Hashable {
//  let div: SBDiv
//}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Div
//struct SBDiv: Codable, Hashable {
//  let pre: SBPre
//}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Pre
//struct SBPre: Codable, Hashable {
//  let text: String
//  let b, h2: [String]
//  
//  enum CodingKeys: String, CodingKey {
//    case text = "#text"
//    case b, h2
//  }
//}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Weather
struct SBWeather: Codable, Hashable {
  let origMetar, origTaf, destMetar, destTaf: String
  let altnMetar, altnTaf, toaltnMetar, toaltnTaf: String
  let eualtnMetar, eualtnTaf, etopsMetar, etopsTaf: String
  
  enum CodingKeys: String, CodingKey {
    case origMetar = "orig_metar"
    case origTaf = "orig_taf"
    case destMetar = "dest_metar"
    case destTaf = "dest_taf"
    case altnMetar = "altn_metar"
    case altnTaf = "altn_taf"
    case toaltnMetar = "toaltn_metar"
    case toaltnTaf = "toaltn_taf"
    case eualtnMetar = "eualtn_metar"
    case eualtnTaf = "eualtn_taf"
    case etopsMetar = "etops_metar"
    case etopsTaf = "etops_taf"
  }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Weights
struct SBWeights: Codable, Hashable {
  let oew, paxCount, bagCount, paxCountActual: Int
  let bagCountActual, paxWeight, bagWeight, freightAdded: Int
  let cargo, payload, estZfw, maxZfw: Int
  let estTow, maxTow, maxTowStruct: Int
  let towLimitCode: String
  let estLdw, maxLdw, estRamp: Int
  
  enum CodingKeys: String, CodingKey {
    case oew
    case paxCount = "pax_count"
    case bagCount = "bag_count"
    case paxCountActual = "pax_count_actual"
    case bagCountActual = "bag_count_actual"
    case paxWeight = "pax_weight"
    case bagWeight = "bag_weight"
    case freightAdded = "freight_added"
    case cargo, payload
    case estZfw = "est_zfw"
    case maxZfw = "max_zfw"
    case estTow = "est_tow"
    case maxTow = "max_tow"
    case maxTowStruct = "max_tow_struct"
    case towLimitCode = "tow_limit_code"
    case estLdw = "est_ldw"
    case maxLdw = "max_ldw"
    case estRamp = "est_ramp"
  }
}
