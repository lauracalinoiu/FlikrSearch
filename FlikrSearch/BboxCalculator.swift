//
//  BboxCalculator.swift
//  FlikrSearch
//
//  Created by Laura Calinoiu on 21/09/15.
//  Copyright © 2015 3Smurfs. All rights reserved.
//

import Foundation

class BboxCalculator {
    let BOUNDING_BOX_HALF_WIDTH = 1.0
    let BOUNDING_BOX_HALF_HEIGHT = 1.0
    let LAT_MIN = -90.0
    let LAT_MAX = 90.0
    let LON_MIN = -180.0
    let LON_MAX = 180.0
    
    var latitude: String?
    var longitude: String?
    
    init(latitude: String?, longitude: String?){
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func computeCalculation() -> String{
        guard let dLat = Double(latitude!) else{
            return ""
        }
        
        guard let dLng  = Double(longitude!) else {
            return ""
        }
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(dLng - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(dLat - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(dLng + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(dLat + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
}