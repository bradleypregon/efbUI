//
//  Extensions.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/6/23.
//

import Foundation
import UIKit
import SwiftUI
import CoreLocation
import MapKit

extension Double {
  func rounded(toPlaces places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}

extension String {
  static let userSimbriefID = "userSimbriefID"
  static let userOwnshipRegistration = "userOwnshipRegistration"
  static let userNotificationsEnabled = "userNotificationsEnabled"
  static let lastIcao = "lastIcao"
  static let distanceListSeedRequired = "distanceListSeedRequired"
}
