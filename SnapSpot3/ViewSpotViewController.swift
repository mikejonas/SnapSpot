//
//  ViewSpotViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/30/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewSpotViewController: UIViewController, UIScrollViewDelegate {

    let kStatusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
    let kScreenSize = UIScreen.mainScreen().bounds
    let kMargin:CGFloat = 15
    var kHeaderHeight:CGFloat?
    var kImageHeight:CGFloat!
    
    var scrollView: UIScrollView!
    var imageView : UIImageView?
    var spotDescriptionText:UITextView = UITextView()
    
    var mapView:GMSMapView!
    var marker = GMSMarker()
    
    var spotImages: [UIImage] = []
    var locationCoordinates: CLLocation?
    var address: String?
    
    let tapImageRec = UITapGestureRecognizer()
    var spot:AnyObject?
    
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    override func viewDidAppear(animated: Bool) {
        editSpotVc.delegate = self
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let kNavigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        kHeaderHeight = kStatusBarHeight + 0
        setupImages()

        scrollView = UIScrollView(frame: CGRectMake(0, kScreenSize.width, kScreenSize.width, kScreenSize.height - kScreenSize.width))
        self.view.addSubview(scrollView)
        scrollView.scrollEnabled = true
        self.scrollView.delegate = self
        
        self.spotImages.append(UIImage(named: "Barcelona")!)
        self.loadSnappedImages(self.spotImages)
    
        setupSpotDescription(spotDescriptionText)
        spotDescriptionText.delegate = self

        self.mapView = GMSMapView()
        setupMap()
        self.scrollView.contentSize = CGSizeMake(kScreenSize.width, spotDescriptionText.bounds.height + mapView.bounds.height + kMargin)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editButtonTapped(sender: UIButton) {
        self.presentViewController(editSpotVc, animated: false) { () -> Void in
//            editSpotVc.addImage(image)
//            editSpotVc.updateMapAndReverseGeocode(photoCoordiantes)
        }
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    func setupImages() {
        println(kStatusBarHeight)
        self.imageView = UIImageView(frame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.width))
        self.imageView?.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(imageView!)
    }
    
    
    
    func loadSnappedImages(imageArray:[UIImage]) {
        for var i = 0; i < imageArray.count; ++i {
            imageView!.image = imageArray[i]
            imageView!.clipsToBounds = true
            imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        }
    }
    
    func setupSpotDescription(textView:UITextView) {
        textView.editable = false
        textView.dataDetectorTypes = UIDataDetectorTypes.Link
        textView.scrollEnabled = false
        textView.frame = CGRectMake(0, 0, kScreenSize.width, 30)
        textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        textView.text = "Lorem ipsum #dolor sit consectetur adipiscing elit."
        self.scrollView.addSubview(textView)
        textView.resolveHashTags()
        textView.font = UIFont.systemFontOfSize(15)
        textView.sizeToFit()
        textView.layoutIfNeeded()
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, kScreenSize.width, textView.frame.height)
    }
    
    func setupMap() {
        mapView.frame = CGRectMake(0, spotDescriptionText.bounds.height + kMargin, kScreenSize.width, kScreenSize.width / 1.3)
        self.scrollView.addSubview(mapView)
        mapView.mapType = kGMSTypeHybrid
        mapView.settings.setAllGesturesEnabled(false)
        let coordinates = CLLocationCoordinate2D(latitude: 41.386486, longitude: 2.1700022)
        updateMap(coordinates)
    }
    func updateMap(coordinates:CLLocationCoordinate2D?) {
        if let coordinates = coordinates {
            
            let zoom18CameraCoordiantes = CLLocationCoordinate2D(latitude: coordinates.latitude + 0.00007, longitude: coordinates.longitude)
            let camera = GMSCameraPosition.cameraWithTarget(zoom18CameraCoordiantes, zoom: 18)
            mapView.camera = camera
            marker.map = mapView
            marker.position = coordinates
        }
        else {
            let coordinates = CLLocationCoordinate2DMake(38, -90)
            let camera = GMSCameraPosition.cameraWithTarget(coordinates, zoom: 2)
            mapView.camera = camera
            marker.map = nil
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//-------------------
//Edit Spot Delegate
//-------------------
extension ViewSpotViewController: EditSpotViewControllerDelegate {
    func spotClosed() {
        println("delegate from view spot vc closed")
        dismissViewControllerAnimated(false, completion: nil)
        editSpotVc.delegate = nil
    }
    func spotSaved() {
        println("delegate from view spot vc saved")
        dismissViewControllerAnimated(true, completion: nil)
        editSpotVc.delegate = nil
    }
}

//-------------------
//Text View Delegate
//-------------------

extension ViewSpotViewController:UITextViewDelegate {
    
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {

        // check for our fake URL scheme hash:helloWorld
        if URL.scheme == "hash" {
            let alertView = UIAlertView()
            alertView.title = "hash tag detected"
            // get a handle on the payload
            alertView.message = "\(URL.resourceSpecifier!)"
            alertView.addButtonWithTitle("Ok")
            alertView.show()
        }
        return true
    }
}
