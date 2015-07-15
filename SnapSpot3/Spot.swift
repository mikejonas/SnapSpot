//
//  Spot.swift
//  SnapSpot2
//
//  Created by Mike Jonas on 5/10/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation
import UIKit
import MapKit

struct Spot {
    var location:CLLocation?
    var ISOcountryCode:String?
    var country:String?
    var postalCode:String?
    var administrativeArea:String?
    var subAdministrativeArea:String?
    var locality:String?
    var subLocality:String?
    var thoroughfare:String?
    var region:CLRegion?
    var inlandWater:String?
    var ocean:String?
    var areasOfInterest:[AnyObject]?
    var addressString:String?
}