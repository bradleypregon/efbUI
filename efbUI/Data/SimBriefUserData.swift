//
//  SimBriefUserData.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/15/24.
//

import SwiftData

@Model
final class UserSettings {
  var simbriefUserID: String?
  var ownshipRegistration: String?
  
  var outboundDistance: Int
  var atisDistance: Int
  var inboundDistance: Int
  var shortInboundDistance: Int
  var finalDistance: Int
  
  init(simbriefUserID: String? = nil, ownshipRegistration: String? = nil, outboundDistance: Int = 20, atisDistance: Int = 40, inboundDistance: Int = 20, shortInboundDistance: Int = 10, finalDistance: Int = 5) {
    self.simbriefUserID = simbriefUserID
    self.ownshipRegistration = ownshipRegistration
    self.outboundDistance = outboundDistance
    self.atisDistance = atisDistance
    self.inboundDistance = inboundDistance
    self.shortInboundDistance = shortInboundDistance
    self.finalDistance = finalDistance
  }
}
