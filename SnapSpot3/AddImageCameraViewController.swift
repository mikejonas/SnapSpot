//
//  AddImageCameraViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/9/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

protocol AddImageCameraViewControllerDelegate {
    func addImageCanceled()
    func ImageAdded(image:UIImage)
}

class AddImageCameraViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var cameraView: CameraView!
    let photoPicker = TWPhotoPickerController()
    var delegate: AddImageCameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        self.view.sendSubviewToBack(cameraView)
        navigationBar.frame=CGRectMake(0, 0, self.view.frame.size.width, 64)  // Here you can set you Width and Height for your navBar
    }
    override func viewWillAppear(animated: Bool) {
        cameraView.startCaptureSessionIfStopped()
    }
    override func viewWillDisappear(animated: Bool) {
        cameraView.stopCaptureSessionIfRunning()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBarButtonItemTapped(sender: UIBarButtonItem) {
        delegate?.addImageCanceled()
    }
    
}

//-------------------
//Camera Delegate
//-------------------
extension AddImageCameraViewController: CameraViewDelegate {
    func cameraViewimagePickerTapped() {
        self.presentViewController(photoPicker, animated: true, completion: nil)
        photoPicker.cropBlock = { (image:UIImage!, coord2d: CLLocationCoordinate2D) -> () in
            self.delegate?.ImageAdded(image)
            if(coord2d.latitude != 0 && coord2d.longitude != 0){
                print(coord2d.latitude, coord2d.longitude)
            }
        }
    }
    func cameraViewShutterButtonTapped(image: UIImage?) {
            self.delegate?.ImageAdded(image!)
        
    }
}
