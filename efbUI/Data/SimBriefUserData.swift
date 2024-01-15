//
//  SimBriefUserData.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/15/24.
//

import SwiftData

@Model
final class SimBriefUser {
  var userID: String
  
  init(userID: String) {
    self.userID = userID
  }
}
