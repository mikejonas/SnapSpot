//
//  CameraVController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/3/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var debugTextView: UITextView!
    var debugi:Int = 0


    
    let photoPicker = TWPhotoPickerController()
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = nil
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        cameraView.startCaptureSessionIfStopped()
    }
    override func viewDidAppear(animated: Bool) {
        editSpotVc.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.delegate = self
    }
    override func viewWillDisappear(animated: Bool) {
        cameraView.stopCaptureSessionIfRunning()
    }
    @IBAction func leftBarButtonItemTapped(sender: UIBarButtonItem) {
        pageController.goToPreviousVC()
    }
    @IBAction func rightBarButtonItemTapped(sender: UIBarButtonItem) {
        pageController.goToNextVC()
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
            var photoCoordiantes: CLLocationCoordinate2D?
            if coord2d.latitude != 0 {photoCoordiantes = coord2d}
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.presentViewController(editSpotVc, animated: false) { () -> Void in
                    editSpotVc.addImage(image)
                    editSpotVc.updateMapAndReverseGeocode(photoCoordiantes)
                }
            })
        }
    }
    func cameraViewShutterButtonTapped(image: UIImage?) {
        editSpotVc.addImage(image!)
        presentViewController(editSpotVc, animated: false) { () -> Void in
            editSpotVc.updateMapAndReverseGeocode(self.appDelegate.coreLocationController!.locationCoordinates?.coordinate)
        }
    }
}

//-------------------
//Edit Spot Delegate
//-------------------
extension CameraViewController: EditSpotViewControllerDelegate {
    func spotClosed() {
        dismissViewControllerAnimated(false, completion: nil)
        editSpotVc.delegate = nil
    }
    
    func spotSaved(spotComponents: SpotComponents) {
        saveSpotLocally(spotComponents)
        dismissViewControllerAnimated(true, completion: nil)
        editSpotVc.delegate = nil
        pageController.goToNextVC()
    }
}