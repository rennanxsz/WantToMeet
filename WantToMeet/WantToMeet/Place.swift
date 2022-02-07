//
//  Place.swift
//  WantToMeet
//
//  Created by Rennan Bruno on 06/02/22.
//

import Foundation
import MapKit

struct Place {
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let address: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
}
