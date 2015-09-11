//
//  AddressComponents.swift
//  SnapSpotGoogleMaps
//
//  Created by Mike Jonas on 6/25/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation

struct SpotAddressComponents: Printable {
    var coordinates: CLLocationCoordinate2D?
    var locality: String? // City
    var administrativeArea: String? // State
    var country: String? // Country
    var fullAddress: String?
    var description: String {
        return " coordinates: \(coordinates) \n locality: \(locality) \n administrative area: \(administrativeArea) \n country: \(country) \n fullAddress \(fullAddress)"
    }
}