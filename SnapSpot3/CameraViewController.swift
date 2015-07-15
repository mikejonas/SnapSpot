//
//  CameraViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/3/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
   
    //IBOUTLETS
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var debugTextView: UITextView!
    var debugi:Int = 0
    
    //VC INIT
    let editSpotVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editSpotViewController") as! EditSpotViewController!
    let photoPicker = TWPhotoPickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //DELEGATES
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
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.editSpotVc.addImage(image)
                
                if(coord2d.latitude != 0 && coord2d.longitude != 0){
                    self.editSpotVc.coordinates = coord2d
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