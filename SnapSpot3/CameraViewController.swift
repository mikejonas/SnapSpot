//
//  CameraViewController.swift
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

    let editSpotVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editSpotViewController") as! EditSpotViewController!
    let photoPicker = TWPhotoPickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.delegate = self
        editSpotVc.delegate = self
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
            var photoCoordiantes: CLLocationCoordinate2D?
            if coord2d.latitude != 0 {photoCoordiantes = coord2d}
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.presentViewController(self.editSpotVc, animated: false) { () -> Void in
                    self.editSpotVc.addImage(image)
                    self.editSpotVc.updateMapAndReverseGeocode(photoCoordiantes)
                }
            })
        }
    }
    func cameraViewShutterButtonTapped(image: UIImage?) {
        editSpotVc.addImage(image!)
        presentViewController(self.editSpotVc, animated: false) { () -> Void in
            self.editSpotVc.updateMapAndReverseGeocode(self.appDelegate.coreLocationController!.locationCoordinates?.coordinate)
        }
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