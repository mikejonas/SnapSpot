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
    var locationStatus = "Not Started"
    var locationCoordinates: CLLocation?
    
    var startTime : NSDate!
    let REQ_ACC : CLLocationAccuracy = 10
    let REQ_TIME : NSTimeInterval = 10

    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 5.0
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

    }

    func getLocation(accuracy:CLLocationAccuracy, maxTime:NSTimeInterval) {
        let startTime = NSDate()
        
        var helloWorldTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "sayHello", userInfo: nil, repeats: true)
        
        func sayHello()
        {
            NSLog("hello World")
        }
        
        let elapsed = locationCoordinates?.timestamp.timeIntervalSinceDate(self.startTime)
        let currentAccuracy = locationCoordinates?.horizontalAccuracy
        
        if elapsed > maxTime {
            println("\(maxTime) elapsed")
            
        }
        if currentAccuracy < 0 || currentAccuracy > accuracy {
            
        }
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
        let location = locations.last as! CLLocation
        self.locationCoordinates = location
        println("UPDATED! \(location.timestamp)")
    }
}