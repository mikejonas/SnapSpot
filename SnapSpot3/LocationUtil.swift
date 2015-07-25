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

    var counter:Double = 0
    func getCoordinatesWithDelayUpTo(#seconds:Double, completion:(CLLocationCoordinate2D?) -> Void) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var locationCoordinates:CLLocation?
        let interval:Double = 0.20
        let intervals:Double = seconds / interval
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            do {
                locationCoordinates = appDelegate.coreLocationController?.locationCoordinates
                println("\(self.counter++) <= \(intervals)")
                if let locationCoordinates = locationCoordinates {
                    println(locationCoordinates.horizontalAccuracy)
                    if locationCoordinates.horizontalAccuracy < 6 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(locationCoordinates.coordinate)
                        })
                        println("BREAK!")
                        self.counter = 0
                        break
                    }
                }
                NSThread.sleepForTimeInterval(interval)
            } while self.counter <= intervals
        })
        
        if locationCoordinates?.horizontalAccuracy <= 5 || counter <= intervals {
            completion(locationCoordinates?.coordinate)
        } else {
            completion(locationCoordinates?.coordinate)
        }
    }
    

}
