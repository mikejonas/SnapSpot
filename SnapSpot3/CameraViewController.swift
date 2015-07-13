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
        photoPicker.cropBlock = { (image:UIImage!) -> () in
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.editSpotVc.addImage(image)
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
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //        if (locationFixAchieved == false) {
        //            locationFixAchieved = true
        //            var locationArray = locations as NSArray
        //            var locationObj = locationArray.lastObject as CLLocation
        //            self.locationCoordinates = locationObj
        //        }
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        self.locationCoordinates = locationObj
        
        //        LocationUtil.getLocationAddress(locationCoordinates, getLocCompletionHandler: { (addressString, error) -> Void in
        //            self.debugTextView.text = "\(self.debugi)a:\(addressString!) \(self.locationCoordinates!.horizontalAccuracy) \n\n " + self.debugTextView.text
        //
        //            self.debugi++
        //        })
        //
        //        LocationUtil.getLocationAddress2(locationCoordinates!)
    }
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.Denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
        if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
            locationManager.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }
}