//
//  AtisApiSchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 4/7/24.
//

import Foundation

struct AtisAPISchema: Decodable, Hashable {
  let airport, type, code, datis: String
}
