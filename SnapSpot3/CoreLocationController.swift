//
//  CoreLocationController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/15/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation
import CoreLocation

class CoreLocationController : NSObject, CLLocationManagerDelegate {

    var locationManager:CLLocationManager = CLLocationManager()
    var locationStatus : NSString = "Not Started"
    var locationCoordinates: CLLocation?

    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 5.0
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        switch status {
        case CLAuthorizationStatus.Restricted: locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.Denied: locationStatus = "User denied access to location"
        case CLAuthorizationStatus.NotDetermined: locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
        // Start location services
        shouldIAllow ? locationManager.startUpdatingLocation() : NSLog("Denied access: \(locationStatus)")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        self.locationCoordinates = locationObj
//        println("\(self.locationCoordinates!.horizontalAccuracy), \(self.locationCoordinates?.coordinate.latitude)")
    }
}

//extension CoreLocationController {
//    func getLocationWithDelay(delay:Float) -> CLLocationCoordinate2D? {
//        let accuracy = locationCoordinates?.horizontalAccuracy
//        let coordinates = locationCoordinates?.coordinate
//        println(accuracy)
//        
//        if coordinates != nil {
//            return coordinates
//        } else {
//            return nil
//        }
//    }
//}

