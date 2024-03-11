//
//  SigmetSchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/10/24.
//

import Foundation

struct SigmetSchemaElement: Codable {
    let airSigmetId: Int
    let icaoId, alphaChar, receiptTime, creationTime: String
    let validTimeFrom, validTimeTo: Int
    let airSigmetType, hazard: String
    let severity, altitudeLow1, altitudeLow2, altitudeHi1: Int?
    let altitudeHi2, movementDir, movementSpd: Int?
    let rawAirSigmet: String
    let postProcessFlag: Int
    let coords: [SigmetCoord]
}

struct SigmetCoord: Codable {
    let lat, lon: Double
}

typealias SigmetSchema = [SigmetSchemaElement]
