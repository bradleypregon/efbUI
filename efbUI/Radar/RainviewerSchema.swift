//
//  RainviewerSchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 2/4/24.
//

import Foundation

// MARK: - RainviewerSchema
struct RainviewerSchema: Codable {
    let version: String?
    let generated: Int?
    let host: String?
    let radar: Radar?
    let satellite: Satellite?
}

// MARK: - Radar
struct Radar: Codable {
    let past, nowcast: [Nowcast]?
}

// MARK: - Nowcast
struct Nowcast: Codable {
    let time: Int?
    let path: String?
}

// MARK: - Satellite
struct Satellite: Codable {
    let infrared: [Nowcast]?
}
