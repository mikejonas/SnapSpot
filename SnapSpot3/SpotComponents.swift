//
//  SpotComponents.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/24/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation

struct SpotComponents: Printable {
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

func saveSpotLocally(components: SpotComponents) {
    //Create Parse class named spot and save data to the class
    let spot = PFObject(className: "Spot")
    spot["caption"] = components.caption
    spot["hashTags"] = components.hashTags
    if let images = components.images {
        spot["localImagePaths"] = saveImageLocallyFromApp(images)
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
    if let administrativeArea = components.addressComponents?.administrativeArea {
        spot["administrativeArea"] = administrativeArea
    }
    if let country = components.addressComponents?.country {
        spot["country"] = country
    }
    spot.pinInBackgroundWithBlock{ success, error in
        println("Object has been saved locally.")
    }
}


func saveSpot(components: SpotComponents) {
    //Create Parse class named spot and save data to the class
    let spot = PFObject(className: "Spot")
    spot["caption"] = components.caption
    spot["hashTags"] = components.hashTags
    if let images = components.images {
        if images.count > 0 {
            let imageData:NSData = UIImageJPEGRepresentation(images[0], 0.5)
            let imageFile:PFFile = PFFile(data: imageData)
            spot["image1"] = imageFile
        }
        if images.count > 1 {
            let imageData1:NSData = UIImageJPEGRepresentation(images[0], 0.5)
            let imageFile1:PFFile = PFFile(data: imageData1)
            spot["image2"] = imageFile1
        }
        if images.count > 2 {
            let imageData2:NSData = UIImageJPEGRepresentation(images[0], 0.5)
            let imageFile2:PFFile = PFFile(data: imageData2)
            spot["image3"] = imageFile2
        }
    }
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
    if let administrativeArea = components.addressComponents?.administrativeArea {
        spot["administrativeArea"] = administrativeArea
    }
    if let country = components.addressComponents?.country {
        spot["country"] = country
    }

    spot.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        println("Object has been saved to cloud.")
    }
}



//THIS NEEDS TO BE FIXED: isImageSaved DOESN'T REALLY DO ANYTHING.
func saveImageLocallyFromApp(images:[UIImage]) -> [String]? {
    var isImageSaved:Bool = false
    var savedImages:[String] = []
    if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String] {
        let dir = dirs[0] //documents directory
        for image in images {
            let imageFileName = randomStringWithLength(7)
            let path = dir.stringByAppendingPathComponent(imageFileName)
            let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
            let result = jpgImageData.writeToFile(path, atomically: true)
            savedImages.append(imageFileName)
            isImageSaved = true
        }
    }
    return isImageSaved ? savedImages : nil
}

func retrieveImageLocally(imageFileNames:[String]) -> [UIImage] {
    var images:[UIImage] = []
    if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String] {
        let dir = dirs[0] //documents directory
        
        //reading
        for imageFileName in imageFileNames {
            let path = dir.stringByAppendingPathComponent(imageFileName)
            let imageData = NSData(contentsOfFile: path)
            images.append(UIImage(data: imageData!)!)
        }
    }
    return images
}





func randomStringWithLength(len:Int) -> String {
    let letters:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var randomString = ""
    for (var i=0; i < len; i++){
        var length:UInt32 = UInt32(count(letters))
        var rand = arc4random_uniform(length)
        randomString.append(letters[advance(letters.startIndex, Int(rand))])
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
