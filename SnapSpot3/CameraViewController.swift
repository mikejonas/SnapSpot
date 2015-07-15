//
//  CameraViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/3/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import CoreLocation


class CameraViewController: UIViewController {
   
    //IBOUTLETS
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var debugTextView: UITextView!
    var debugi:Int = 0
    
   
    //VC INIT
    let editSpotVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editSpotViewController") as! EditSpotViewController!
    let photoPicker = TWPhotoPickerController()
    
    //LOCATION
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var locationManager: CLLocationManager!
    var locationCoordinates: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //DELEGATES
        cameraView.delegate = self
        editSpotVc.delegate = self
        
        //LOCATION
        initLocationManager()
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = nil
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        cameraView.startCaptureSessionIfStopped()
    }
    override func viewWillDisappear(animated: Bool) {
        cameraView.stopCaptureSessionIfRunning()
    }
}


//-------------------
//Camera Delegate
//-------------------
extension CameraViewController: CameraViewDelegate {
    func cameraViewimagePickerTapped() {
        self.presentViewController(photoPicker, animated: true, completion: nil)
        
        //CROPBLOCK
        photoPicker.cropBlock = { (image:UIImage!, coord2d: CLLocationCoordinate2D) -> () in
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.editSpotVc.addImage(image)
                if(coord2d.latitude != 0 && coord2d.longitude != 0){
                    println(coord2d.latitude, coord2d.longitude)
                }
                self.presentViewController(self.editSpotVc, animated: false, completion: nil)
            })
        }
        
    }
    func cameraViewShutterButtonTapped(image: UIImage?) {
        self.editSpotVc.addImage(image!)
        self.presentViewController(self.editSpotVc, animated: false, completion: nil)
    }
}

//-------------------
//Edit Spot Delegate
//-------------------
extension CameraViewController: EditSpotViewControllerDelegate {
    func spotClosed() {
        dismissViewControllerAnimated(false, completion: nil)
    }
    func spotSaved() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//-------------------
//LOCATION Delegate
//-------------------
extension CameraViewController: CLLocationManagerDelegate {
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        self.locationCoordinates = locationObj
        
        if let coord2d = locationCoordinates?.coordinate {
            self.debugTextView.text = "\(self.debugi): \(coord2d.latitude, coord2d.longitude) \(self.locationCoordinates!.horizontalAccuracy) \n\n " + self.debugTextView.text
            self.debugi++
        }
        println("locationManager didupdatelocation")
//        LocationUtil.getLocationAddress2(locationCoordinates, getLocCompletionHandler: { (spot:Spot, error) -> Void in
//        })
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
}