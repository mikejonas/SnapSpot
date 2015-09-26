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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSBundle.mainBundle().loadNibNamed("CameraView", owner: self, options: nil)
        self.addSubview(view)
    }
    override func layoutSubviews() {
        self.view.frame = screenSize
        print(screenSize)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.view.frame = screenSize
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
                        print("Capture device Back found")
                        beginSession()
                    }
                }
                if(device.position == AVCaptureDevicePosition.Front) {
                    captureDeviceFront = device as? AVCaptureDevice
                    if captureDeviceFront != nil {
                        print("Capture device Front found")
                    }
                }
            }
        }
        
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }

    
        
    }
    
    

    @IBAction func imagePickerButtonPressed(sender: UIButton) {
        delegate?.cameraViewimagePickerTapped()
    }
    
    
    //-------------
    //CAMERA
    //-------------
    //IBACTION: TAKE PHOTO
    @IBAction func shutterButtonPressed(sender: UIButton) {
        
    // Get the image
        let videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        if videoConnection != nil {
            self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection)
                { (imageDataSampleBuffer, error) -> Void in
                    self.imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    let convertedImage = UIImage(data: self.imageData!)!
                    let croppedImage = ImageUtil.scaleAndCropImage(convertedImage)
                    self.delegate?.cameraViewShutterButtonTapped(croppedImage)
            }
        } else {
            self.delegate?.cameraViewShutterButtonTapped(nil)
            print("ELSE???")
        }

    }
    
    @IBAction func switchCameraButtonPressed(sender: UIButton) {
        captureSession.beginConfiguration()
        if captureDeviceInputFront == nil {
            do {
                captureDeviceInputFront = try AVCaptureDeviceInput(device: captureDeviceFront)
            } catch {
                print("Can't add capture device front")
            }
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
        print("loadWithBackCamera")
        captureSession.beginConfiguration()
        if captureDeviceInputFront == nil {
            do {
                captureDeviceInputFront = try AVCaptureDeviceInput(device: captureDeviceFront)
            } catch {
                print("CATCH: Can't add capture device front")
            }
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
            do {
                try device.lockForConfiguration()
            } catch {
                print("CATCH: device lock for configureation (device: \(device))")
            }
            
            
            //            device.flashMode = AVCaptureFlashMode.On
            device.unlockForConfiguration()
        }
    }
    
    func beginSession() {
        configureDevice()
        do {
            captureDeviceInputBack = try AVCaptureDeviceInput(device: captureDeviceBack)
            captureSession.addInput(captureDeviceInputBack)
        } catch {
            print("CATCH: Can't add capture device front")
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = screenSize
        captureSession.startRunning()
    }

    /**
        REQUIRED In viewWillAppear of camera view controller.
        Fixes bug with sessions running on two camera view controllers.
    */
    func startCaptureSessionIfStopped() {
        if captureSession.running == false {
            captureSession.startRunning()
        }
    }
    /**
        REQUIRED In viewWillDisappear of camera view controller.
        Fixes bug with sessions running on two camera view controllers.
    */
    func stopCaptureSessionIfRunning() {
        if captureSession.running == true {
            captureSession.stopRunning()
        }
    }
    
    
    func focusAndExposeAtPoint(point: CGPoint) {
        var device: AVCaptureDevice
        isInputBack ? (device = self.captureDeviceBack!) : (device = self.captureDeviceFront!)
        
        let viewSize:CGSize = self.view.bounds.size
        
        do {
            try device.lockForConfiguration()
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
        catch {
            print("CATCH: ERROR Device.lockForConfiguration")
        }
    }
    
    //Get coordinates of touch and focus / expose at that point
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInView(self.view)
            focusAndExposeAtPoint(location)
        }
    }
        
    

}
