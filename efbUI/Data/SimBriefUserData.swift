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
  var inboundDistance: Int
  var finalDistance: Int
  
  init(simbriefUserID: String? = nil, ownshipRegistration: String? = nil, outboundDistance: Int = 20, inboundDistance: Int = 20, finalDistance: Int = 5) {
    self.simbriefUserID = simbriefUserID
    self.ownshipRegistration = ownshipRegistration
    self.outboundDistance = outboundDistance
    self.inboundDistance = inboundDistance
    self.finalDistance = finalDistance
  }
}
