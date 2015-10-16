//
//  SpotComponents.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/24/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation

struct SpotComponents: CustomStringConvertible {
    var localObjectID: String?
    var user: String?
    var caption: String?
    var hashTags: [String]?
    var localImagePaths: [String] = []
    var images: [UIImage] = []
    var addressComponents = SpotAddressComponents()
    var date:NSDate?
    var isSynced:Bool?
    var description: String {
        return "\n caption: \(caption) \n hashTags: \(hashTags) \n images: \(images) \(localImagePaths) \n addressComponents: \(addressComponents)"
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

func convertFirebaseObjectToSpotComponents(spotObject:AnyObject) -> SpotComponents {
    
    let location = spotObject["location"]
    let coordiantes = spotObject["coordinates"]
    
    let spotAddressComponents = SpotAddressComponents(
        coordinates: getCoordinatesFromlatlng(spotObject["lat"] as? Double, lng: spotObject["lng"] as? Double),
        locality: spotObject["locality"] as? String,
        subLocality: spotObject["subLocality"] as? String,
        administrativeArea: spotObject["administrativeArea"] as? String,
        country: spotObject["country"] as? String,
        fullAddress: spotObject["address"] as? String
    )
    
    let spotComponents = SpotComponents(
        localObjectID: nil,
        user: nil,
        caption: spotObject["caption"] as? String,
        hashTags: spotObject["hashTags"] as? [String],
        localImagePaths: spotObject["localImagePaths"] as! [String],
        images: [],
        addressComponents: spotAddressComponents,
        date: convertTimeStampToNSDate(spotObject["date"] as? Double),
        isSynced: nil
    )
    
    return spotComponents
}

func convertTimeStampToNSDate(timeStamp:Double?) -> NSDate? {
    if let timeStamp = timeStamp {
        return NSDate(timeIntervalSince1970: timeStamp)
    } else {
        return nil
    }
}

func getCoordinatesFromlatlng(lat:Double?, lng:Double?) ->CLLocationCoordinate2D? {
    print("LAT: \(lat), LNG: \(lng)")
    if let lat = lat, lng = lng {
        return CLLocationCoordinate2DMake(lat,lng)
    } else {
        return nil
    }
}


func saveSpotLocally(components: SpotComponents) {
    print(components)
    
    let ref = Firebase(url: "https://snapspot.firebaseio.com")
    let spotsRef = ref.childByAppendingPath("spots")
    
    var newSpot = [String:AnyObject]()
    var newSpotLocation = [String:AnyObject]()
    
    newSpot["caption"] = components.caption
    newSpot["hashTags"] = components.hashTags
    newSpot["localImagePaths"] = components.localImagePaths
    saveImagesLocally(components.images, newImagePaths: newSpot["localImagePaths"] as! [String])
    newSpot["date"] = components.date?.timeIntervalSince1970
    if let coordinates = components.addressComponents.coordinates {
        newSpotLocation["coordinates"] = ["lat" : coordinates.latitude, "lng" : coordinates.longitude]
    }
    if let address = components.addressComponents.fullAddress {
        newSpotLocation["address"] = address
    }
    if let locality = components.addressComponents.locality {
        newSpotLocation["locality"] = locality
    }
    if let subLocality = components.addressComponents.subLocality {
        newSpotLocation["subLocality"] = subLocality
    }
    if let administrativeArea = components.addressComponents.administrativeArea {
        newSpotLocation["administrativeArea"] = administrativeArea
    }
    if let country = components.addressComponents.country {
        newSpotLocation["country"] = country
    }
    newSpot["location"] = newSpotLocation
    let newSpotRef = spotsRef.childByAutoId()
    newSpotRef.setValue(newSpot)
    
    
    
    
//    //Create Parse class named spot and save data to the class
//    let spotObject = PFObject(className: "Spot")
//    spotObject["localObjectID"] = randomStringWithLength(10)
//    if let user = components.user {
//        spotObject["user"] = user
//    }
//    spotObject["caption"] = components.caption
//    spotObject["hashTags"] = components.hashTags
//    spotObject["localImagePaths"] = components.localImagePaths
//    print(components.localImagePaths)
//    saveImagesLocally(components.images, newImagePaths: spotObject["localImagePaths"] as! [String])
//    spotObject["date"] = components.date
//
//    spotObject["isSynced"] = false
//    if let coordinates = components.addressComponents.coordinates {
//        let geopoint = PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
//        spotObject["coordinates"] = geopoint
//    }
//    if let address = components.addressComponents.fullAddress {
//        spotObject["address"] = address
//    }
//    if let locality = components.addressComponents.locality {
//        spotObject["locality"] = locality
//    }
//    if let subLocality = components.addressComponents.subLocality {
//        spotObject["subLocality"] = subLocality
//    }
//    if let administrativeArea = components.addressComponents.administrativeArea {
//        spotObject["administrativeArea"] = administrativeArea
//    }
//    if let country = components.addressComponents.country {
//        spotObject["country"] = country
//    }
//    spotObject.pinInBackgroundWithBlock{ success, error in
//        print("Object has been saved locally.")
//        spotObject.saveEventually({ (success, error) -> Void in
//            
//        })
//    }
}

func editSpotLocally(components: SpotComponents) {
//    let query = PFQuery(className:"Spot")
//    query.fromLocalDatastore()
//    query.whereKey("localObjectID", equalTo: components.localObjectID!)
//    query.getFirstObjectInBackgroundWithBlock { (returnedSpotObject, error) -> Void in
//        if let spotObject = returnedSpotObject  {
//            
//            let newComponentsImagePaths = components.localImagePaths
//            let localComponentsImagePaths = spotObject["localImagePaths"] as! [String]
//            
//            //DELETE IMAGES
//            var imagesToDelete:[String] = []
//            for imagePath in localComponentsImagePaths {
//                if !newComponentsImagePaths.contains(imagePath) {
//                    imagesToDelete.append(imagePath)
//                }
//            }
//            deleteImagesLocallyFromApp(imagesToDelete)
//            //Save Images
//            var imagesToSave:[UIImage] = []
//            var imagePathsToSave:[String] = []
//            for (i, newImagePath) in newComponentsImagePaths.enumerate() {
//                if !localComponentsImagePaths.contains(newImagePath) {
//                    imagesToSave.append(components.images[i])
//                    imagePathsToSave.append(newImagePath)
//                }
//            }
//            saveImagesLocally(imagesToSave, newImagePaths: imagePathsToSave)
//
//            spotObject["localObjectID"] = components.localObjectID
//            if let user = components.user {
//                spotObject["user"] = user
//            }
//            spotObject["caption"] = components.caption
//            spotObject["hashTags"] = components.hashTags
//            spotObject["localImagePaths"] = newComponentsImagePaths
//            spotObject["date"] = components.date
//            spotObject["isSynced"] = components.isSynced
//            if let coordinates = components.addressComponents.coordinates {
//                let geopoint = PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
//                spotObject["coordinates"] = geopoint
//            }
//            if let address = components.addressComponents.fullAddress {
//                spotObject["address"] = address
//            }
//            if let locality = components.addressComponents.locality {
//                spotObject["locality"] = locality
//            }
//            if let subLocality = components.addressComponents.subLocality {
//                spotObject["subLocality"] = subLocality
//            }
//            if let administrativeArea = components.addressComponents.administrativeArea {
//                spotObject["administrativeArea"] = administrativeArea
//            }
//            if let country = components.addressComponents.country {
//                spotObject["country"] = country
//            }
//            
//            spotObject.saveEventually({ (isSaved, error) -> Void in
//                print("ERROR \(error)")
//                print("IsSaved \(isSaved)")
//            })
//        }
//    }
}

func deleteSpotLocally(spotComponents: SpotComponents) {
//    let query = PFQuery(className:"Spot")
//    query.fromLocalDatastore()
//    query.whereKey("date", equalTo: spotComponents.date!)
//    query.getFirstObjectInBackgroundWithBlock { (returnedSpotObject, error) -> Void in
//        if let spotObject = returnedSpotObject  {
//            spotObject.unpinInBackgroundWithBlock({ (success, error) -> Void in
//                if success {
//                    print(deleteImagesLocallyFromApp(spotObject["localImagePaths"] as? [String]))
//                    spotObject.deleteEventually()
//                }
//            })
//        }
//    }
}


func saveImagesLocally(newImages:[UIImage], newImagePaths:[String]){
    if let dirs:[String] = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as [String] {
        let dir = dirs[0] //documents directory
        for (i, image) in newImages.enumerate() {
//            let imageFileName = "\(randomStringWithLength(7)).jpg"
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(newImagePaths[i])
            if let jpgImageData = UIImageJPEGRepresentation(image, 0.4) {
                let result = jpgImageData.writeToURL(path, atomically: true)
                print("image Saved?: \(result)")
            }
        }
    }

}

func getAllImageURLS() -> [NSURL] {
    let fileManager = NSFileManager.defaultManager()
    var files:[NSURL] = []
    // We need just to get the documents folder url
    let documentsUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
    do {
        // if you want to filter the directory contents you can do like this:
        if let directoryUrls = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) {
            files = directoryUrls
        }
    }
    return files
}

func deleteImagesLocallyFromApp(imageFileNames:[String]?) -> [String] {
    var deletedImages:[String] = []
    if let imageFileNames = imageFileNames {
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
        randomString.append(letters[letters.startIndex.advancedBy(Int(rand))])
    }
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
