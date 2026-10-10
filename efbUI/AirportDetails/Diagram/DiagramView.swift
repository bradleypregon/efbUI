//
//  DiagramView.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/3/26.
//

import SwiftUI
import MapKit

struct DiagramView: View {
  var runways: [RunwayTable] = []
  var towerCoord: CLLocationCoordinate2D?
  
  var body: some View {
    Canvas { context, size in
      // Runway ends, width (start, end, width) as map points
      let strips: [(
        start: MKMapPoint,
        end: MKMapPoint,
        width: Double,
        ident: String,
        coord: CLLocationCoordinate2D
      )] = runways.compactMap { rwy in
        guard
          let lat = rwy.runwayLatitude,
          let lon = rwy.runwayLongitude,
          let bearing = rwy.runwayTrueBearing,
          let length = rwy.runwayLength else {
          return nil
        }
        
        let pointsPerFoot = MKMapPointsPerMeterAtLatitude(lat) * 0.3048 // normalize
        let start = MKMapPoint(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        let radians = bearing * .pi / 180
        let distance = Double(length) * pointsPerFoot
        let end = MKMapPoint(x: start.x + sin(radians) * distance,
                             y: start.y - cos(radians) * distance)
        return (
          start,
          end,
          Double(rwy.runwayWidth ?? 100) * pointsPerFoot,
          rwy.runwayIdentifier,
          CLLocationCoordinate2D(latitude: lat, longitude: lon)
        )
      }
      guard !strips.isEmpty else { return }
      
      // Bounding box for rwys
      var rect = MKMapRect.null
      for strip in strips {
        rect = rect.union(MKMapRect(origin: strip.start, size: MKMapSize()))
        rect = rect.union(MKMapRect(origin: strip.end, size: MKMapSize()))
      }
      
      // Tower
      if let coord = towerCoord {
        rect = rect.union(MKMapRect(origin: MKMapPoint(coord), size: MKMapSize()))
      }

      // Fit into Canvas view
      let scale = min(size.width / max(rect.width, 1), size.height / max(rect.height, 1)) * 0.9
      
      func project(_ p: MKMapPoint) -> CGPoint {
        CGPoint(x: (p.x - rect.midX) * scale + size.width / 2,
                y: (p.y - rect.midY) * scale + size.height / 2)
      }
      
      // Draw on Canvas
      for strip in strips {
        var path = Path()
        path.move(to: project(strip.start))
        path.addLine(to: project(strip.end))
        context.stroke(path, with: .color(.gray), lineWidth: max(strip.width * scale * 1.5, 3))
      }
      
      // Runways on top of strips
      for strip in strips {
        context.draw(
          Text(strip.ident)
            .font(.title2)
            .fontWeight(.semibold),
          at: project(MKMapPoint(.init(latitude: strip.coord.latitude, longitude: strip.coord.longitude)))
        )
      }
      
      if let towerIcon = context.resolveSymbol(id: "tower-pin"),
          let coord = towerCoord {
        context.draw(towerIcon, at: project(MKMapPoint(coord)))
      }
      
    } symbols: {
      Image(systemName: "star.fill")
        .font(.title2)
        .tag("tower-pin")
    }
    .aspectRatio(1, contentMode: .fit)
  }
  
}

#Preview {
  DiagramView(
    runways: RunwayTable.mockKDSM,
    towerCoord: .init(latitude: 41.53899537428175, longitude: -93.6574274572825)
  )
}
