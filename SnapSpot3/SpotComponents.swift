//
//  SpotComponents.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/24/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation

struct SpotComponents: CustomStringConvertible {
    var caption: String?
    var hashTags: [String]?
    var localImagePaths: [String]?
    var images: [UIImage]?
    var addressComponents: SpotAddressComponents?
    var date:NSDate?
    var isSynced:Bool?

    var description: String {
        return "\n caption: \(caption) \n hashTags: \(hashTags) \n images: \(images) \n addressComponents: \(addressComponents)"
    }
}

struct SpotAddressComponents: CustomStringConvertible {
    var coordinates: CLLocationCoordinate2D?
    var locality: String? // City
    var subLocality: String? // Also City
    var administrativeArea: String? // State
    var country: String? // Country
    var fullAddress: String?
    var description: String {
        return " coordinates: \(coordinates) \n locality: \(locality) \n sublocality: \(subLocality) \n administrative area: \(administrativeArea) \n country: \(country) \n fullAddress \(fullAddress)"
    }
}

func convertParseObjectToSpotComponents(spotObject:PFObject) -> SpotComponents {
    
    var coordinates: CLLocationCoordinate2D?
    if let pfCoordinates = spotObject["coordinates"] as? PFGeoPoint {
        coordinates = CLLocationCoordinate2D(latitude: pfCoordinates.latitude, longitude: pfCoordinates.longitude)
    }
    
    let spotAddressComponents = SpotAddressComponents(
        coordinates: coordinates,
        locality: spotObject["locality"] as? String,
        subLocality: spotObject["subLocality"] as? String,
        administrativeArea: spotObject["administrativeArea"] as? String,
        country: spotObject["country"] as? String,
        fullAddress: spotObject["address"] as? String
    )
    
    let spotComponents = SpotComponents(
        caption: spotObject["caption"] as? String,
        hashTags: spotObject["hashTags"] as? [String],
        localImagePaths: spotObject["localImagePaths"] as? [String],
        images: nil,
        addressComponents: spotAddressComponents,
        date: spotObject["date"] as? NSDate,
        isSynced: spotObject["isSynced"] as? Bool
    )
    
    return spotComponents
}



func saveSpotLocally(components: SpotComponents) {
    
    //Create Parse class named spot and save data to the class
    let spot = PFObject(className: "Spot")
    spot["caption"] = components.caption
    spot["hashTags"] = components.hashTags
    if let images = components.images {
        spot["localImagePaths"] = saveImagesLocally(images)
    }
    spot["date"] = components.date

    spot["isSynced"] = false
    if let coordinates = components.addressComponents?.coordinates {
        let geopoint = PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
        spot["coordinates"] = geopoint
    }
    if let address = components.addressComponents?.fullAddress {
        spot["address"] = address
    }
    if let locality = components.addressComponents?.locality {
        spot["locality"] = locality
    }
    if let subLocality = components.addressComponents?.subLocality {
        spot["subLocality"] = subLocality
    }
    if let administrativeArea = components.addressComponents?.administrativeArea {
        spot["administrativeArea"] = administrativeArea
    }
    if let country = components.addressComponents?.country {
        spot["country"] = country
    }
    spot.pinInBackgroundWithBlock{ success, error in
        print("Object has been saved locally.")
        spot.saveEventually({ (success, error) -> Void in
            
        })
    }
}

func editSpotLocally(spotComponents: SpotComponents, deleteSpot:Bool) {
    print(spotComponents)
    print("THE DATE!!! \(spotComponents.date!)")
    let query = PFQuery(className:"Spot")
    query.fromLocalDatastore()
    query.whereKey("date", equalTo: spotComponents.date!)
    query.getFirstObjectInBackgroundWithBlock { (returnedSpotObject, error) -> Void in
        if let spotObject = returnedSpotObject  {
            print("OBJECT FOUND!!!")
            print(spotObject)

            
            spotObject["caption"] = "!!! :-)"
            
            spotObject.saveEventually({ (isSaved, error) -> Void in
                print("ERROR \(error)")
                print("IsSaved \(isSaved)")
            })
            
//            spotObject.setObject(<#T##object: AnyObject##AnyObject#>, forKey: <#T##String#>)
//            spotObject.unpinInBackgroundWithBlock({ (success, error) -> Void in
//                if success {
//                    if deleteSpot {
//                        print(deleteImagesLocallyFromApp(object["localImagePaths"] as! [String]))
//                    } else {
//                        saveSpotLocally(spotComponents)
//                    }
//                }
//            })
        }
    }
}


//THIS NEEDS TO BE FIXED: isImageSaved DOESN'T REALLY DO ANYTHING.
func saveImagesLocally(images:[UIImage]) -> [String]? {
    var isImageSaved:Bool = false
    var savedImages:[String] = []
    if let dirs:[String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as [String] {
        let dir = dirs[0] //documents directory
        for image in images {
            let imageFileName = randomStringWithLength(7)
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(imageFileName) //???
            if let jpgImageData = UIImageJPEGRepresentation(image, 1.0) {
                let result = jpgImageData.writeToURL(path, atomically: true) //???
                print("image Saved?: \(result)")
            }
            savedImages.append(imageFileName)
            isImageSaved = true
        }
    }
    return isImageSaved ? savedImages : nil
}

func deleteImagesLocallyFromApp(imageFileNames:[String]) -> [String] {
    var deletedImages:[String] = []
    if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as [String] {
        let dir = dirs[0] //documents directory
        let fileManager = NSFileManager.defaultManager()
        for imageFileName in imageFileNames {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(imageFileName)
            
            do {
                try fileManager.removeItemAtURL(path)
                deletedImages.append(imageFileName)

            } catch {
                print("IMAGE NOT DELETED")
            }
            
        }
    }
    return deletedImages
}

func retrieveImagesLocally(imageFileNames:[String]) -> [UIImage] {
    var images:[UIImage] = []
    if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as [String] {
        let dir = dirs[0] //documents directory
        
        //reading
        for imageFileName in imageFileNames {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(imageFileName)
            if let imageData = NSData(contentsOfURL: path) {
                images.append(UIImage(data: imageData)!)
            }

        }
    }
    return images
}







func randomStringWithLength(len:Int) -> String {
    let letters:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    var randomString = ""
    for (var i=0; i < len; i++){
        let length:UInt32 = UInt32(letters.characters.count)
        let rand = arc4random_uniform(length)
        randomString.append(letters[letters.startIndex.advancedBy(Int(rand))]) //???
    }
    randomString = "\(String(randomString)).jpg"
    return randomString
}




//func convertSpotsObjectToSpotComponents(spotsObject:[String:AnyObject]) -> SpotComponents {
//    var spotComponents = SpotComponents()
//    spotComponents.caption = spotsObject["caption"] as? String
//    spotComponents.hashTags = spotsObject["hashTags"] as? [String]
//    if let image1 = spotsObject["image1"]
//    spotComponents.images?.append()
//    
//    
//    return spotComponents
//}
