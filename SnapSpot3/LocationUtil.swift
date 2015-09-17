//
//  LocationUtil.swift
//  SnapSpot2
//
//  Created by Mike Jonas on 4/20/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps


class LocationUtil: CLLocation {
    func reverseGeoCodeCoordinate(coordinate:CLLocationCoordinate2D, completion:(spotAddressComponents:SpotAddressComponents!) -> Void) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            var spotAddressComponents:SpotAddressComponents?
            if let address = response?.firstResult() {
                let fullAddress = ", ".join(address.lines as! [String])
                spotAddressComponents = SpotAddressComponents(
                    coordinates: CLLocationCoordinate2D(latitude: address.coordinate.latitude, longitude: address.coordinate.longitude),
                    locality: address.locality,
                    administrativeArea: address.administrativeArea,
                    country: address.country,
                    fullAddress: fullAddress
                )
            } else {
                spotAddressComponents = SpotAddressComponents(coordinates: coordinate, locality: nil, administrativeArea: nil, country: nil, fullAddress: "\(coordinate.latitude), \(coordinate.longitude)")
            }
            completion(spotAddressComponents: spotAddressComponents)
        }
    }
}
