//
//  ViewSpotViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 8/14/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import GoogleMaps
class ViewSpotViewController: UIViewController {
    
    var spotObject: PFObject?
    var images: [UIImage]?
    var superViewScreenShot:UIImage?
    var dateFormatter = NSDateFormatter()
    var locationCoordinates:CLLocationCoordinate2D?
    var isScrolledTOMap:Bool = false
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewSubView: UIView!
    @IBOutlet weak var statusBarBackgroundView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var captionTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var addressTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: GMSMapView!
    var marker = GMSMarker()
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var appleMapsButton: ButtonIconRight!
    @IBOutlet weak var googleMapsButton: ButtonIconRight!
    @IBOutlet weak var CloseMapsBar: UIVisualEffectView!
    @IBOutlet weak var closeMapsBarNub: UIVisualEffectView!
    
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var backButtonFrame = CGRect()
    var editButtonFrame = CGRect()
    var imageScrollViewHeight = CGFloat()
    var mapViewTopPosition = CGFloat()
    var mapViewMinHeight = CGFloat()
    var mapViewMaxHeight = CGFloat()
    var mapViewAmountPassedScreen = CGFloat()

    
    override func viewWillAppear(animated: Bool) {
        reloadData(spotObject!)
    }
    
    override func viewDidAppear(animated: Bool) {
        editSpotVc.delegate = self

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.backgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 0.6)
        backButton.titleLabel?.font = UIFont.fontAwesomeOfSize(15)
        backButton.setTitle(String.fontAwesomeIconWithName(FontAwesome.ChevronDown), forState: .Normal)
        backButton.layer.cornerRadius = 16
        
        editButton.backgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 0.6)
//        editButton.titleLabel?.font = UIFont.fontAwesomeOfSize(15)
//        editButton.setTitle(String.fontAwesomeIconWithName(FontAwesome.Pencil), forState: .Normal)
//        editButton.setAttributedTitle(<#title: NSAttributedString!#>, forState: <#UIControlState#>)
        editButton.layer.cornerRadius = 16
        
        
        
        editButtonFrame = editButton.frame
        backButtonFrame = backButton.frame
        self.scrollView.delegate = self
        self.captionTextView.delegate = self
        

        
        if let screenShot = superViewScreenShot {
            let backgroundView = UIImageView(image: screenShot)
            self.view.addSubview(backgroundView)
        } else {
            self.view.backgroundColor = UIColor.darkGrayColor()
        }
        
        statusBarBackgroundView.hidden = true
        captionTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
        addressTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
        setupMap()
        appleMapsButton.layer.cornerRadius = 4
        googleMapsButton.layer.cornerRadius = 4
        CloseMapsBar.alpha = 1
        
        closeMapsBarNub.layer.cornerRadius = 4
        closeMapsBarNub.clipsToBounds = true
        
//        println(spotObject)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateTextViewSizes(captionTextView, constraint: captionTextViewHeightConstraint)
        updateTextViewSizes(addressTextView, constraint: addressTextViewHeightConstraint)
        mapViewTopPosition = addressTextView.frame.height + addressTextView.frame.origin.y // - 40
        mapViewMinHeight = screenSize.height - mapViewTopPosition
        if mapViewMinHeight < 0 {
            mapViewMinHeight = 0
        }
        
        if mapViewTopPosition > screenSize.height {
            mapViewAmountPassedScreen = mapViewTopPosition - screenSize.height
        } else {
            mapViewAmountPassedScreen = 0
        }
        mapViewMaxHeight = screenSize.height - addressTextView.frame.height - 20
        mapView.frame = CGRectMake(mapView.frame.origin.x, mapView.frame.origin.y, mapView.frame.width, mapViewMaxHeight)
        mapViewHeightConstraint.constant = mapView.frame.height

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData(spotObject:PFObject) {
        isScrolledTOMap = false
        CloseMapsBar.hidden = true
        
        //Image
        let imageFileNames = spotObject["localImagePaths"] as? [String]
        let images = retrieveImageLocally(imageFileNames!)
        self.images = images
        imageScrollView.setupWithImages(images)
        imageScrollView.clipsToBounds = true
        imageScrollViewHeight = imageScrollView.bounds.width
        
        //Caption
        let caption = spotObject["caption"] as? String
        captionTextView.text = spotObject["caption"] as? String
        captionTextView.resolveHashTags()
        var attrs = [
            NSFontAttributeName : UIFont.systemFontOfSize(11.0),
            NSForegroundColorAttributeName: UIColor.lightGrayColor()
        ]
        let timeStamp = spotObject["date"] as! NSDate
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let dateString = "Added: \(dateFormatter.stringFromDate(timeStamp))"

        captionTextView.appendAttributedText(dateString, attributes: attrs)
        
        //Address
        let address = spotObject["address"] as? String
        addressTextView.text = address


        //Map
        if let pfCoordinates = spotObject["coordinates"] as? PFGeoPoint {
            locationCoordinates = CLLocationCoordinate2D(latitude: pfCoordinates.latitude, longitude: pfCoordinates.longitude)
            updateMap(locationCoordinates)
        }
    }
    
    func updateTextViewSizes(textView:UITextView, constraint:NSLayoutConstraint) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
        constraint.constant = textView.frame.height
    }
    
    func setupMap() {
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
        if !isScrolledTOMap { scrollDownToMap() }
    }
    
    func scrollDownToMap() {
        var bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
        self.scrollView.setContentOffset(bottomOffset, animated: true)
        mapView.settings.setAllGesturesEnabled(true)
        isScrolledTOMap = true
        UIView.animateWithDuration(0.3, animations: {
            self.CloseMapsBar.frame =  CGRectMake(0, self.CloseMapsBar.frame.origin.y, self.CloseMapsBar.frame.width, 25)
            }, completion: {
                (value: Bool) in
                self.CloseMapsBar.hidden = false
        })
    }
    
    func scrollUpFromMap() {
        var bottomOffset = CGPointMake(0, 0 - self.scrollView.contentInset.top);
        self.scrollView.setContentOffset(bottomOffset, animated: true)
        mapView.settings.setAllGesturesEnabled(false)
        isScrolledTOMap = false
        
        UIView.animateWithDuration(0.3, animations: {
            self.CloseMapsBar.frame =  CGRectMake(0, self.CloseMapsBar.frame.origin.y, self.CloseMapsBar.frame.width, 0)
            }, completion: {
                (value: Bool) in
                self.CloseMapsBar.hidden = true
        })
    }
    
    @IBAction func appleMapsButtonTapped(sender: ButtonIconRight) {
        if let coordinates = locationCoordinates {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?q=\(coordinates.latitude),\(coordinates.longitude)&t=Hybrid")!)
        }
        
    }
    @IBAction func googleMapsButtonTapped(sender: ButtonIconRight) {
        if let coordinates = locationCoordinates {
            if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
                UIApplication.sharedApplication().openURL(NSURL(string:
                    "comgooglemapsurl://maps.google.com/maps?q=\(coordinates.latitude),\(coordinates.longitude)&views=satellite,traffic&source=SourceApp&x-success=sourceapp://?resume=true")!)
            } else {
                UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/de/app/google-maps/id585027354?mt=8")!)
            }
        }
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editButtonTapped(sender: UIButton) {
        self.presentViewController(editSpotVc, animated: false) { () -> Void in
            //Do stuff
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
//Scroll View Delegate
//-------------------

extension ViewSpotViewController:UIScrollViewDelegate {


    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var scrollY = scrollView.contentOffset.y
        var bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
        
        if scrollY < -40 {
            println(scrollY)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            if self.isScrolledTOMap == false {
                if scrollY > 0 { self.scrollDownToMap() }
            } else {
                if scrollY < bottomOffset.y { self.scrollUpFromMap() }
            }
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var scrollY = scrollView.contentOffset.y - mapViewAmountPassedScreen

        if scrollY > 0 {
            
            if scrollY > imageScrollViewHeight - 70 {
                backButton.frame = CGRectMake(backButton.frame.origin.x, imageScrollViewHeight - 70  + 22 - scrollY, backButton.frame.size.width, backButton.frame.size.height)
                editButton.frame = CGRectMake(editButton.frame.origin.x, imageScrollViewHeight - 70  + 22 - scrollY, editButton.frame.size.width, editButton.frame.size.height)
            } else {
                backButton.frame = backButtonFrame
                editButton.frame = editButtonFrame
            }
            
            if scrollY > imageScrollViewHeight - 20 {
                //CHANGE VIEW WILL DISSAPEAR TO WORK WITH CHANGING STATUS BARS!!!
                UIApplication.sharedApplication().statusBarStyle = .Default
                statusBarBackgroundView.hidden = false
            } else {
                statusBarBackgroundView.hidden = true
                UIApplication.sharedApplication().statusBarStyle = .LightContent
            }
        }
        
//        CloseMapsBar.frame = CGRectMake(0, CloseMapsBar.frame.origin.y, CloseMapsBar.frame.width, 25 - (scrollY / 10))
    }
}

//-------------------
//Text View Delegate
//-------------------

extension ViewSpotViewController:UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        // check for our fake URL scheme hash:helloWorld
        if URL.scheme == "hash" {
            Globals.variables.filterSpotsHashtag = [URL.resourceSpecifier!]
            self.dismissViewControllerAnimated(true, completion: nil)

        }
        return true
    }
}

//-------------------
//Edit Spot Delegate
//-------------------
extension ViewSpotViewController: EditSpotViewControllerDelegate {
    func spotClosed() {
        println("delegate from view spot vc closed")
        dismissViewControllerAnimated(false, completion: nil)
    }
    func spotSaved(spotComponents: SpotComponents) {
        println("delegate from view spot vc saved")
        dismissViewControllerAnimated(true, completion: nil)
    }
}

