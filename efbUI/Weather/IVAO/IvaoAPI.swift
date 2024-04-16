//
//  IvaoAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 4/16/24.
//

import Foundation
// TODO: Handle 500, 404, etc statusCodes

class IvaoAPI {
  func fetchATIS(icao: String) async throws -> String {
    let endpoint = ""
    guard let url = URL(string: endpoint) else { throw IVAOError.badURL }
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
      throw IVAOError.badResponse
    }
    return "ivao atis"
  }
  
  func fetchMETAR(icao: String) async throws -> String {
    let endpoint = ""
    guard let url = URL(string: endpoint) else { throw IVAOError.badURL }
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
      throw IVAOError.badResponse
    }
    return "ivao metar"
  }
  
  func fetchTAF(icao: String) async throws -> String {
    let endpoint = ""
    guard let url = URL(string: endpoint) else { throw IVAOError.badURL }
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
      throw IVAOError.badResponse
    }
    return "ivao taf"
  }
}

enum IVAOError: Error {
  case badURL
  case badResponse
}
