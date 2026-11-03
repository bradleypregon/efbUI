//
//  RainviewerSchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 2/4/24.
//

import Foundation

struct LibrewxrSchema: Codable {
    let version: String?
    let generated: Int?
    let host: String?
    let radar: Radar?
    let satellite: Satellite?
}

struct Radar: Codable {
    let past, nowcast: [Nowcast]?
}

struct Nowcast: Codable {
    let time: Int
    let path: String?
}

struct Satellite: Codable {
    let infrared: [Nowcast]?
}
