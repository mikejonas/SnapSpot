//
//  CameraViewControllerOld.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/3/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import AssetsLibrary

class CameraViewControllerOld: UIViewController, CLLocationManagerDelegate {
    
    let editSpotVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editSpotViewController") as! EditSpotViewController!
    
    @IBOutlet weak var cameraControlsView: UIView!
    
    //Camera
    var imageData: NSData!
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput = AVCaptureStillImageOutput()
    var captureDeviceBack : AVCaptureDevice?
    var captureDeviceFront : AVCaptureDevice?
    var captureDeviceInputBack : AVCaptureInput?
    var captureDeviceInputFront : AVCaptureInput?
    var isInputBack:Bool = true
    
    //LOCATION
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var locationManager: CLLocationManager!
    var locationCoordinates: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        //CAMERA
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDeviceBack = device as? AVCaptureDevice
                    if captureDeviceBack != nil {
                        println("Capture device Back found")
                        beginSession()
                    }
                }
                if(device.position == AVCaptureDevicePosition.Front) {
                    captureDeviceFront = device as? AVCaptureDevice
                    if captureDeviceFront != nil {
                        println("Capture device Front found")
                    }
                }
            }
        }
        editSpotVc.delegate = self
        
        //LOCATION
        initLocationManager()
        
        
        
        //Translucence
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = cameraControlsView.bounds
        cameraControlsView.addSubview(visualEffectView)
        cameraControlsView.backgroundColor = UIColor.clearColor()
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = nil
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEditSpotControllerSegue" {
                            //let destinationVC = segue.destinationViewController as! EditSpotController
                            //destinationVC.imageData = self.imageData
                            //destinationVC.pickedImage = self.pickedImage
                            //destinationVC.locationCoordinates = self.locationCoordinates
        }
    }
    
    
    
    @IBAction func imagePickerButtonPressed(sender: UIButton) {
        let photoPicker = TWPhotoPickerController()
        self.presentViewController(photoPicker, animated: true, completion: nil)
        photoPicker.cropBlock = { (image:UIImage!) -> () in
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.editSpotVc.addImage(image)
                self.presentViewController(self.editSpotVc, animated: false, completion: nil)
            })
        }
        
    }
    
    
    //-------------
    //CAMERA
    //-------------
    //IBACTION: TAKE PHOTO
    @IBAction func shutterButtonPressed(sender: UIButton) {
        
        //Get Location when photo is taken
        locationCoordinates = locationManager.location
        
        // Get the image
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        let delay = 0.25 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            var videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
            if videoConnection != nil {
                self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo))
                    { (imageDataSampleBuffer, error) -> Void in
                        self.imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
//                        self.performSegueWithIdentifier("ShowEditSpotControllerSegue", sender: self)
                        self.presentViewController(self.editSpotVc, animated: false, completion: nil)

                }
            } else {
                self.presentViewController(self.editSpotVc, animated: false, completion: nil)
            }
        }
    }
    
    @IBAction func switchCameraButtonPressed(sender: UIButton) {
        captureSession.beginConfiguration()
        if captureDeviceInputFront == nil {
            var err : NSError? = nil
            captureDeviceInputFront = AVCaptureDeviceInput(device: captureDeviceFront, error: &err)
        }
        
        if isInputBack {
            captureSession.removeInput(captureDeviceInputBack)
            captureSession.addInput(captureDeviceInputFront)
            isInputBack = false
        } else {
            captureSession.removeInput(captureDeviceInputFront)
            captureSession.addInput(captureDeviceInputBack)
            isInputBack = true
        }
        captureSession.commitConfiguration()
    }
    
    
    
    func configureDevice() {
        if let device = captureDeviceBack {
            device.lockForConfiguration(nil)
            //            device.flashMode = AVCaptureFlashMode.On
            device.unlockForConfiguration()
        }
    }
    
    func beginSession() {
        configureDevice()
        var err : NSError? = nil
        
        //        captureDeviceInputFront = AVCaptureDeviceInput(device: captureDeviceFront, error: &err)
        captureDeviceInputBack = AVCaptureDeviceInput(device: captureDeviceBack, error: &err)
        
        captureSession.addInput(captureDeviceInputBack)
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    
    
    func focusAndExposeAtPoint(point: CGPoint) {
        
        var device: AVCaptureDevice
        isInputBack ? (device = self.captureDeviceBack!) : (device = self.captureDeviceFront!)
        
        let viewSize:CGSize = self.view.bounds.size
        
        if device.lockForConfiguration(nil) {
            if device.focusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                if isInputBack {
                    device.focusPointOfInterest = CGPointMake(point.y / viewSize.height, 1.0 - point.x / viewSize.width)
                } else {
                    device.focusPointOfInterest = CGPointMake(point.y / viewSize.height, point.x / viewSize.width)
                }
                device.focusMode = AVCaptureFocusMode.AutoFocus
            }
            
            if device.exposurePointOfInterestSupported && device.isExposureModeSupported(AVCaptureExposureMode.AutoExpose) {
                if isInputBack {
                    device.exposurePointOfInterest = CGPointMake(point.y / viewSize.height, 1.0 - point.x / viewSize.width)
                } else {
                    device.exposurePointOfInterest = CGPointMake(point.y / viewSize.height, point.x / viewSize.width)
                }
                device.exposureMode = AVCaptureExposureMode.AutoExpose
            }
            //            println(CGPointMake(point.y / viewSize.height, 1.0 - point.x / viewSize.width))
            //            println(CGPointMake(point.y / viewSize.height, point.x / viewSize.width))
            
            //Set exposure and focus back to continuous auto focus
            if device.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus) {
                device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
            }
            if device.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure) {
                device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
            }
            
            device.unlockForConfiguration()
        }
        else {
            // TODO: Log error.
        }
    }
    
    //Get coordinates of touch and focus / expose at that point
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInView(self.view)
            focusAndExposeAtPoint(location)
        }
    }

    

    
    //-------------
    //LOCATION
    //-------------
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

extension CameraViewControllerOld: EditSpotViewControllerDelegate {
    func spotClosed() {
        println("CLOSED!")
        dismissViewControllerAnimated(false, completion: nil)
    }
    func spotSaved() {
        println("Saved")
        dismissViewControllerAnimated(true, completion: nil)
    }
}

    

