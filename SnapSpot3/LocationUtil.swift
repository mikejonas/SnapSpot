//
//  LocationUtil.swift
//  SnapSpot2
//
//  Created by Mike Jonas on 4/20/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AddressBookUI

class LocationUtil: CLLocation {
    
    class func getLocationAddress2(location: CLLocation?, getLocCompletionHandler : (spot:Spot, error : NSError?) -> Void) {
        var geocoder = CLGeocoder()
        println("-> Finding user address...")
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            var placemark:CLPlacemark!
            var spot = Spot()
            if error == nil && placemarks.count > 0 {
                placemark = placemarks[0] as! CLPlacemark
                
                spot.coordinates = location?.coordinate
                if placemark.ISOcountryCode != nil { spot.ISOcountryCode = placemark.ISOcountryCode }
                if placemark.country != nil { spot.country = placemark.country }
                if placemark.postalCode != nil { spot.postalCode = placemark.postalCode }
                if placemark.administrativeArea != nil { spot.administrativeArea = placemark.administrativeArea }
                if placemark.subAdministrativeArea != nil { spot.subAdministrativeArea = placemark.subAdministrativeArea }
                if placemark.locality != nil { spot.locality = placemark.locality }
                if placemark.subLocality != nil { spot.subLocality = placemark.subLocality }
                if placemark.thoroughfare != nil { spot.thoroughfare = placemark.thoroughfare }
                if placemark.region != nil { spot.region = placemark.region}
                if placemark.inlandWater != nil { spot.inlandWater = placemark.inlandWater }
                if placemark.ocean != nil { spot.ocean = placemark.ocean }
                if placemark.areasOfInterest != nil { spot.areasOfInterest = placemark.areasOfInterest }
                spot.addressString = self.makeAddress(placemark)
            }
            
            //Instead of returning the address string, call the 'getLocCompletionHandler'
            getLocCompletionHandler(spot: spot, error: error)
            
        })
    }
    
    private class func makeAddress(placemark:CLPlacemark) -> String {
        var addressString : String = ""
        if placemark.ISOcountryCode == "TW" /*Address Format in Chinese*/ {
            if placemark.country != nil {
                addressString = placemark.country
            }
            if placemark.subAdministrativeArea != nil {
                addressString = addressString + placemark.subAdministrativeArea + ", "
            }
            if placemark.locality != nil {
                addressString = addressString + placemark.locality
            }
            if placemark.thoroughfare != nil {
                addressString = addressString + placemark.thoroughfare
            }
            if placemark.subThoroughfare != nil {
                addressString = addressString + placemark.subThoroughfare
            }
        } else {
            if placemark.subThoroughfare != nil {
                addressString = placemark.subThoroughfare + " "
            }
            if placemark.thoroughfare != nil {
                addressString = addressString + placemark.thoroughfare + ", "
            }
            if placemark.locality != nil {
                addressString = addressString + placemark.locality + ", "
            }
            if placemark.administrativeArea != nil {
                addressString = addressString + placemark.administrativeArea + " "
            }
            if placemark.country != nil {
                addressString = addressString + placemark.country
            }
        }
        return addressString
    }
    
    //                println("isocountryCode: \(spot.ISOcountryCode)")
    //                println("country: \(spot.country)")
    //                println("postalCode: \(spot.postalCode)")
    //                println("administrativeArea \(spot.administrativeArea)")
    //                println("subAdministrativeArea \(spot.subAdministrativeArea)")
    //                println("locality \(spot.locality)")
    //                println("subLocality \(spot.subLocality)")
    //                println("thoroughfare \(spot.thoroughfare)")
    //                println("region \(spot.region)")
    //                println("inlandWater \(spot.inlandWater)")
    //                println("ocean \(spot.ocean)")
    //                println("areasOfInterest \(spot.areasOfInterest)")
    
}
