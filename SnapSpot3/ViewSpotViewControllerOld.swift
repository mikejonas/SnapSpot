//
//  ViewSpotViewControllerOld.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/30/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewSpotViewControllerOld: UIViewController {

    let kStatusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
    let kScreenSize = UIScreen.mainScreen().bounds
    let kMargin:CGFloat = 15
    var kHeaderHeight:CGFloat?
    var kImageHeight:CGFloat!
    
    var spotObject: PFObject?
    
    var scrollView: UIScrollView!
    var imageScrollView : ImageScrollView!
    var caption:UITextView = UITextView()
    var mapView:GMSMapView!
    var marker = GMSMarker()
    
    var spotImages: [UIImage] = []
    var locationCoordinates: CLLocation?
    var address: String?
    
    let tapImageRec = UITapGestureRecognizer()
    var spot:AnyObject?
    
    
    override func viewWillAppear(animated: Bool) {
        reloadData(spotObject!)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    override func viewDidAppear(animated: Bool) {
        editSpotVc.delegate = self
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let kNavigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        kHeaderHeight = kStatusBarHeight + 0

        scrollView = UIScrollView(frame: CGRectMake(0, 0, kScreenSize.width, kScreenSize.height))
        self.view.addSubview(scrollView)
        scrollView.scrollEnabled = true
        self.scrollView.delegate = self
        
        setupImageScrollView()
        setupCaption()
        setupMap()
        self.scrollView.contentSize = CGSizeMake(kScreenSize.width, imageScrollView.bounds.height + caption.bounds.height + mapView.bounds.height + kMargin)
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
    
    
    func setupImageScrollView() {
        self.imageScrollView = ImageScrollView(frame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.width))
        imageScrollView.clipsToBounds = true
        self.scrollView.addSubview(imageScrollView)
    }
    
    
    
    func setupCaption() {
        caption.delegate = self
        caption.editable = false
        caption.dataDetectorTypes = UIDataDetectorTypes.Link
        caption.scrollEnabled = false
        caption.frame = CGRectMake(0, imageScrollView.bounds.height, kScreenSize.width, 130)
        caption.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        caption.font = UIFont.systemFontOfSize(15)
        caption.sizeToFit()
        caption.layoutIfNeeded()
        caption.frame = CGRectMake(caption.frame.origin.x, caption.frame.origin.y, kScreenSize.width, caption.frame.height)
        self.scrollView.addSubview(caption)

    }
    
    func setupMap() {
        self.mapView = GMSMapView()
        mapView.frame = CGRectMake(0, imageScrollView.bounds.height + caption.bounds.height + kMargin, kScreenSize.width, kScreenSize.width / 1.3)
        self.scrollView.addSubview(mapView)
        mapView.mapType = kGMSTypeHybrid
        mapView.settings.setAllGesturesEnabled(false)
        let coordinates = CLLocationCoordinate2D(latitude: 41.386486, longitude: 2.1700022)
        updateMap(coordinates)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("mapViewTapped"))
        mapView.addGestureRecognizer(tap)
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
    func mapViewTapped() {
        let alertController = UIAlertController(title: "Open in Maps", message: nil, preferredStyle: .Alert)
        
        let oneAction = UIAlertAction(title: "Apple Maps", style: .Default) { (_) in }
        let twoAction = UIAlertAction(title: "Google Maps", style: .Default) { (_) in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addAction(oneAction)
        alertController.addAction(twoAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }

    func reloadData(spotObject:PFObject) {
        //Caption
        caption.text = spotObject["caption"] as? String
        caption.resolveHashTags()
        
        //Image
        let imageFileNames = spotObject["localImagePaths"] as? [String]
        let images = retrieveImageLocally(imageFileNames!)
        imageScrollView.setupWithImages(images)
        
        //Map
        if let pfCoordinates = spotObject["coordinates"] as? PFGeoPoint {
            let coord2d = CLLocationCoordinate2D(latitude: pfCoordinates.latitude, longitude: pfCoordinates.longitude)
            updateMap(coord2d)

        }
        
//        spotComponents.hashTags = spotsObject["hashTags"] as? [String]
//        if let image1 = spotsObject["image1"]
//        spotComponents.images?.append()
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
extension ViewSpotViewControllerOld: EditSpotViewControllerDelegate {
    func spotClosed() {
        println("delegate from view spot vc closed")
        dismissViewControllerAnimated(false, completion: nil)
        editSpotVc.delegate = nil
    }
    func spotSaved(spotComponents: SpotComponents) {
        println("delegate from view spot vc saved")
        dismissViewControllerAnimated(true, completion: nil)
        editSpotVc.delegate = nil
    }
}

//-------------------
//Text View Delegate
//-------------------

extension ViewSpotViewControllerOld:UITextViewDelegate {
    
    
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

