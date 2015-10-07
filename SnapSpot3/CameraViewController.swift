//
//  CameraVController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/3/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var cameraView: CameraView!

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
                    editSpotVc.addImage(ImageUtil.scaleImageTo(newWidth: 1080, image: image))
                    editSpotVc.updateMapAndReverseGeocode(photoCoordiantes)
                }
            })
        }
    }
    func cameraViewShutterButtonTapped(image: UIImage?) {
        if let image = image {
            editSpotVc.addImage(ImageUtil.scaleImageTo(newWidth: 1080, image: image))
        }
        presentViewController(editSpotVc, animated: false) { () -> Void in
            
            editSpotVc.refreshLocation(15)
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
    
    func spotSaved(spotComponents: SpotComponents) {
        saveSpotLocally(spotComponents)
        dismissViewControllerAnimated(true, completion: nil)
        pageController.goToNextVC()
    }
    func spotDeleted(spotComponents: SpotComponents) {
        print("THIS SHOULDN't EVER BE PERFORMED")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}