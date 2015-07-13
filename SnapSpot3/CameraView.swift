//
//  CameraView.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/6/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import AVFoundation

    protocol CameraViewDelegate: class {
        func cameraViewShutterButtonTapped(image:UIImage?)
        func cameraViewimagePickerTapped()
    }

    class CameraView: UIView {
        
    weak var delegate:CameraViewDelegate?
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    @IBOutlet var view: UIView!
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSBundle.mainBundle().loadNibNamed("CameraView", owner: self, options: nil)
        self.addSubview(view)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view.backgroundColor = UIColor.blueColor()

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
        
        //Translucence
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = cameraControlsView.bounds
        cameraControlsView.addSubview(visualEffectView)
        cameraControlsView.backgroundColor = UIColor.clearColor()
        
    }
    
    

    @IBAction func imagePickerButtonPressed(sender: UIButton) {
        let photoPicker = TWPhotoPickerController()
        delegate?.cameraViewimagePickerTapped()
        
        //do this stuff
//        self.presentViewController(photoPicker, animated: true, completion: nil)
//        photoPicker.cropBlock = { (image:UIImage!) -> () in
//            self.dismissViewControllerAnimated(false, completion: { () -> Void in
//                self.editSpotVc.addImage(image)
//                
//                self.presentViewController(self.editSpotVc, animated: false, completion: nil)
//            })
//        }
        
    }
    
    
    //-------------
    //CAMERA
    //-------------
    //IBACTION: TAKE PHOTO
    @IBAction func shutterButtonPressed(sender: UIButton) {
        
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
                        let convertedImage:UIImage = UIImage(data: self.imageData!)!
                        let croppedImage = ImageUtil.scaleAndCropImage(convertedImage)
                        self.delegate?.cameraViewShutterButtonTapped(croppedImage)
                }
            } else {
                self.delegate?.cameraViewShutterButtonTapped(nil)
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

    func loadWithBackCamera() {
        println("loadWithBackCamera")
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
        previewLayer?.frame = screenSize
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

    

    

}
