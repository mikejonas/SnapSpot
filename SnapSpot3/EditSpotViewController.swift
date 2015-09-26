//
//  EditSpotViewController.swift
//  SnapSpotGoogleMaps2
//
//  Created by Mike Jonas on 6/30/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

protocol EditSpotViewControllerDelegate {
    func spotClosed()
    func spotSaved(spotComponents:SpotComponents)
    func spotDeleted(spotComponents:SpotComponents)
}

class EditSpotViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    //    @IBOutlet weak var keyboardActiveView: UIView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var photoThumbnail0: UIImageView!
    @IBOutlet weak var photoThumbnail1: UIImageView!
    @IBOutlet weak var photoThumbnail2: UIImageView!
    @IBOutlet weak var editMapLabel: UILabel!
    
    @IBOutlet weak var refreshLocationButton: UIButton!
    @IBOutlet weak var refreshLocationActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationStatusLabel: UILabel!
    @IBOutlet weak var deleteSpotButton: UIButton!
    
    let addImageCameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddImageCameraViewController") as! AddImageCameraViewController
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: "AIzaSyB-0-hv2zKDeYl17vRTaDOPKhuQiZnsXmo",
        placeType: .All
    )
    var delegate: EditSpotViewControllerDelegate?

    let locationUtil = LocationUtil()
    var spotComponents = SpotComponents()
    var marker = GMSMarker()
    var getLocationTimer:NSTimer?
    var getLocationTimerCycles = 0
    var getLocationFound = false

    var captionPlaceholderLabel: UILabel!
    var imageArray: [UIImage] = []
    var imageViewArray: [UIImageView]!
    
    var isEditing:Bool?
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var contentViewFrameHeight = contentView.frame.height
        if deleteSpotButton.hidden == true {
            contentViewFrameHeight = contentView.frame.height - deleteSpotButton.frame.height - 5
        }
        scrollView.contentSize = CGSizeMake(contentView.frame.width, contentViewFrameHeight)


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageViewArray  = [photoThumbnail0, photoThumbnail1, photoThumbnail2]
        setupMap()
        setupImageButtons()
        setupTextView()
        setupTextViewPlaceholder()
        deleteSpotButton.hidden = true
        scrollView.delegate = self
        addImageCameraVC.delegate = self
        gpaViewController.placeDelegate = self

    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBar.frame=CGRectMake(0, 0, self.view.frame.size.width, 64)  // Here you can set you Width and Height for
    }
    

    
    // If I want to resignfirstresponder for touching anywhere
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        if (delegate != nil) {
            delegate?.spotClosed()
            resetView()
        }
        
    }
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        
        //Caption
        spotComponents.caption = captionTextView.text
        if spotComponents.date == nil {
            spotComponents.date = NSDate()
        }
        
        //HashTags
        captionTextView.extractHashTags { extractedHashtags in
            self.spotComponents.hashTags = extractedHashtags
        }
        
        //Image
        spotComponents.images = imageArray

        //CHANGED
//        //Address components
//        spotComponents.addressComponents = spotAddressComponents
        
        if (delegate != nil) {
            delegate?.spotSaved(spotComponents)
            resetView()
        }
    }
    
    @IBAction func deleteSpotButtonTapped(sender: AnyObject) {
        if (delegate != nil) {
            delegate?.spotDeleted(spotComponents)
            resetView()
        }
    }
    
    @IBAction func refreshLocationButttonTapped(sender: UIButton) {
        refreshLocation(10)
    }
    func stopTimerIfRunning() {
        if self.getLocationTimer != nil {
            getLocationTimer?.invalidate()
            getLocationTimerCycles = 0
            getLocationFound = false
            refreshLocationButton.hidden = false
            refreshLocationActivityIndicator.stopAnimating()
        }
    }
    func refreshLocation(secondsToRun:Int) {
        stopTimerIfRunning()
        refreshLocationButton.hidden = true
        refreshLocationActivityIndicator.startAnimating()
        
        let locationController = Globals.constants.appDelegate.coreLocationController
        locationController?.locationManager.stopUpdatingLocation()
        locationController?.locationManager.startUpdatingLocation()
        getLocationTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("performGetLocation"), userInfo: nil, repeats: true)
    }
    
    func performGetLocation() {
        let locationController = Globals.constants.appDelegate.coreLocationController
        let location = locationController!.locationCoordinates
        if getLocationTimerCycles == 0 {
                updateLocationStatusLabel("Estimating Location...", labelSubText:nil, isAnimated:false)
        } else if getLocationTimerCycles < 10{
            print(location?.coordinate)
            if location?.horizontalAccuracy <= 10 && location?.horizontalAccuracy >= 1 {
                self.stopTimerIfRunning()
                updateLocationStatusLabel("Location Found!", labelSubText: " (\(getAccuracy(location!.horizontalAccuracy))% Accuracy)", isAnimated:true)
                self.updateMapAndReverseGeocode(location?.coordinate)
            } else {
                if location?.horizontalAccuracy > 0 {
                    print(location?.horizontalAccuracy)
                }
            }
        } else {
            if location != nil {
                self.stopTimerIfRunning()
                updateLocationStatusLabel("Location Found!", labelSubText: " (\(getAccuracy(location!.horizontalAccuracy))% Accuracy)", isAnimated:true)
                self.updateMapAndReverseGeocode(location?.coordinate)
            } else {
                self.stopTimerIfRunning()
                updateLocationStatusLabel("Not found", labelSubText: " (Refresh or tap Map)", isAnimated:true)
            }
        }
        getLocationTimerCycles = getLocationTimerCycles + 1
    }

    func updateLocationStatusLabel(labelText:String, labelSubText:String?, isAnimated:Bool) {
        let darkTextColor = UIColor(white: 0.1, alpha: 1)
        let lightTextColor = UIColor(white: 0.3, alpha: 1)
        let mainLabelTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15),NSForegroundColorAttributeName: darkTextColor] as Dictionary!
        let labelAttributedText = NSMutableAttributedString(string: labelText, attributes: mainLabelTextAttributes)
        
        if let labelSubText = labelSubText {
            let subLabelTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(14),NSForegroundColorAttributeName: lightTextColor] as Dictionary!
            labelAttributedText.appendAttributedString(NSMutableAttributedString(string: labelSubText, attributes: subLabelTextAttributes))
        }
        
        if isAnimated {
            locationStatusLabel.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.locationStatusLabel.attributedText = labelAttributedText
                self.locationStatusLabel.fadeIn()
                self.locationStatusLabel.sizeToFit()

            })
        } else {
            self.locationStatusLabel.attributedText = labelAttributedText
            self.locationStatusLabel.sizeToFit()

        }

    }
    
    func getAccuracy(meters: CLLocationAccuracy) -> Int {
        if meters <= 5 { return 90 }
        else if meters <= 10 { return 85 }
        else if meters <= 50 { return 80 }
        else if meters <= 100 { return 70 }
        else if meters <= 200 { return 60 }
        else if meters <= 500 { return 50 }
        else if meters <= 1000{ return 30 }
        else { return 20 }
    }
    
    func editSpot(spotComponents:SpotComponents?) {
        
        deleteSpotButton.hidden = false
        if let spotComponents = spotComponents {
            self.spotComponents = spotComponents
            print(spotComponents)

            if let imagePaths = spotComponents.localImagePaths {
                imageArray = retrieveImagesLocally(imagePaths)
            }
            reloadImages()
            
            if let caption = spotComponents.caption {
                captionTextView.text = caption
                if caption != "" {
                    captionPlaceholderLabel.hidden = true
                }
            }
            updateMap(spotComponents.addressComponents)
        }
        
    }
    
    func resetView() { //clear
        imageArray = []
        deleteSpotButton.hidden = true
        captionPlaceholderLabel.hidden = false
        captionTextView.text = nil
        spotComponents = SpotComponents()
        updateMap(nil)
        scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
    }
}



//IMAGE FUNCTIONS
extension EditSpotViewController: AddImageCameraViewControllerDelegate {
    //DELEGATES: addImageCanceled, ImageAdded
    func addImageCanceled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func ImageAdded(image: UIImage) {
        self.dismissViewControllerAnimated(true, completion: nil)
        addImage(image)
    }
}
extension EditSpotViewController {
    func addImage(image:UIImage) {
        imageArray.append(image)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.reloadImages()
        })
    }
    func removeImage(imageIndex:Int) {
        imageArray.removeAtIndex(imageIndex)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.reloadImages()
        })
    }
    func reloadImages() {
        if (imageArray.count == 0) {
            self.photoThumbnail0?.image = nil
        }
        if (imageArray.count >= 1) {
            self.photoThumbnail0?.image = imageArray[0]
            self.photoThumbnail1?.image = nil
            self.photoThumbnail2?.image = nil
        }
        if (imageArray.count >= 2) {
            self.photoThumbnail1?.image = imageArray[1]
            self.photoThumbnail2?.image = nil
        }
        if (imageArray.count == 3) {
            self.photoThumbnail2?.image = imageArray[2]
        }
        self.reloadImageButtons()
    }
    
    func setupImageButtons() {
        for imageView in imageViewArray {
            let imageButton = UIButton()
            imageButton.frame = CGRectMake(imageView.bounds.origin.x, imageView.bounds.origin.y , 60,60)
            imageButton.titleLabel?.font = UIFont.fontAwesomeOfSize(28)
            imageButton.layer.shadowOffset = CGSizeMake(0, 0)
            imageButton.layer.shadowOpacity = 1.0
            imageButton.layer.shadowRadius = 1.0
            
            
            imageButton.addTarget(self, action: Selector("imageButtonTapped:"), forControlEvents: .TouchUpInside)
            imageView.addSubview(imageButton)

        }
    }
    func reloadImageButtons() {
        for imageView in imageViewArray {
            if let imageButton = imageView.subviews[0] as? UIButton {
                if imageView.image != nil {
                    imageButton.setTitle(String.fontAwesomeIconWithName(.Times), forState: .Normal)
                    imageButton.setTitleColor(UIColor(red: 254/255, green: 152/255, blue: 152/255, alpha: 1.0), forState: .Normal)
                    imageButton.layer.opacity = 1
                    imageButton.layer.shadowColor = UIColor.blackColor().CGColor
                } else {
                    imageButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    imageButton.setTitle(String.fontAwesomeIconWithName(.Plus), forState: .Normal)
                    imageButton.layer.opacity = 0.3
                    imageButton.layer.shadowColor = UIColor.clearColor().CGColor
                }
            }
            
        }
    }
    func imageButtonTapped(sender:UIButton!) {
        if let imageIndex = imageViewArray.indexOf(sender.superview as! UIImageView) {

            if sender.titleLabel?.text == String.fontAwesomeIconWithName(.Times) {
                removeImage(imageIndex)
            } else {
                presentViewController(addImageCameraVC, animated: true, completion: nil)
            }
        }
    }
}

//Setup Map functions
extension EditSpotViewController {
    func setupMap() {
        refreshLocationButton.titleLabel?.font = UIFont.fontAwesomeOfSize(15)
        refreshLocationButton.setTitle(String.fontAwesomeIconWithName(.Refresh), forState: .Normal)
        
        let fontAwesomeAttributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(16)] as Dictionary!
        let editMapLabelAttributedString = NSMutableAttributedString(string: String.fontAwesomeIconWithName(.Pencil), attributes: fontAwesomeAttributes)
        editMapLabelAttributedString.appendAttributedString(NSMutableAttributedString(string: " \(editMapLabel.text!)"))
        editMapLabel.attributedText = editMapLabelAttributedString
        

        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("mapViewTapped")))
        mapView.mapType = kGMSTypeHybrid
        mapView.settings.setAllGesturesEnabled(false)
        marker.tappable = false
        updateMap(spotComponents.addressComponents)
    }
    func updateMap(addressComponents:SpotAddressComponents?) {
        if let coordinates = addressComponents?.coordinates {
            //NEW ADD MARKER LABEL
            let zoom18CameraCoordiantes = CLLocationCoordinate2D(latitude: coordinates.latitude + 0.00007, longitude: coordinates.longitude)
            let camera = GMSCameraPosition.cameraWithTarget(zoom18CameraCoordiantes, zoom: 18)
            mapView.camera = camera
            marker.map = mapView
            marker.position = coordinates
            self.updateMarkerModal(self.spotComponents.addressComponents!)

        }
        else {
            let coordinates = CLLocationCoordinate2DMake(38, -90)
            let camera = GMSCameraPosition.cameraWithTarget(coordinates, zoom: 2)
            mapView.camera = camera
            marker.map = nil
        }

    }
    func updateMapAndReverseGeocode(coordinates:CLLocationCoordinate2D?) {
        if let coordinates = coordinates {
            spotComponents.addressComponents?.coordinates = coordinates
            updateMap(spotComponents.addressComponents)

            
            locationUtil.reverseGeoCodeCoordinate(coordinates, completion: { (updatedAddressComponents) -> Void in
                self.spotComponents.addressComponents = updatedAddressComponents
                self.updateMarkerModal(self.spotComponents.addressComponents!)
            })
        }
    }
    func mapViewTapped() {
        //REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR
        presentViewController(gpaViewController, animated: true) { () -> Void in
            self.gpaViewController.gpaViewController.spotAddressComponents = self.spotComponents.addressComponents
            self.gpaViewController.gpaViewController.updateMap(self.spotComponents.addressComponents?.coordinates)
            self.gpaViewController.gpaViewController.searchBar.text = self.spotComponents.addressComponents?.fullAddress
            self.gpaViewController.gpaViewController.searchBarAddressText = self.spotComponents.addressComponents?.fullAddress
        }
    }
    
    func updateMarkerModal(addressComponents:SpotAddressComponents?) -> () {
        if let address = addressComponents {
            let addressString = address.fullAddress!
            var markerTitleAndSnippet:(title: String?, snippet: String?)
            if let locality = address.locality {
                if let localityPosition = addressString.rangeOfString(locality, options: .BackwardsSearch)?.startIndex {
                    markerTitleAndSnippet.title = addressString.substringToIndex(localityPosition.predecessor())
                    markerTitleAndSnippet.snippet = addressString.substringFromIndex(localityPosition)
                }
            } else {
                markerTitleAndSnippet.1 = addressString
            }
            marker.title = markerTitleAndSnippet.title
            marker.snippet = markerTitleAndSnippet.snippet
            mapView.selectedMarker = marker
        }
    }
}

extension EditSpotViewController: GooglePlacesAutocompleteDelegate {
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
        self.updateMarkerModal(self.spotComponents.addressComponents)
    }
    func placeSaved() {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            self.spotComponents.addressComponents = self.gpaViewController.gpaViewController.spotAddressComponents
            self.updateMap(self.spotComponents.addressComponents)
            self.updateMarkerModal(self.spotComponents.addressComponents)
        })
    }
}

extension EditSpotViewController: UITextViewDelegate {
    func setupTextView() {

        captionTextView.layer.masksToBounds = true
        captionTextView.textContainerInset = UIEdgeInsetsMake(10,5,10,5)
        captionTextView.clipsToBounds = true
        captionTextView.layer.shadowColor = UIColor.blackColor().CGColor
        captionTextView.layer.shadowOffset = CGSizeMake(0, 1)
        captionTextView.layer.shadowOpacity = 0.2
        captionTextView.layer.shadowRadius = 1.0
        captionTextView.layer.shouldRasterize = false
    }
    
    func setupTextViewPlaceholder() {
        captionTextView.delegate = self
        captionPlaceholderLabel = UILabel()
        captionPlaceholderLabel.text = "Caption / #tags"
        captionPlaceholderLabel.font = captionTextView.font
        captionPlaceholderLabel.sizeToFit()
        captionTextView.addSubview(captionPlaceholderLabel)
        captionPlaceholderLabel.frame.origin = CGPointMake(10, 10)
        captionPlaceholderLabel.textColor = UIColor(white: 0, alpha: 0.5)
        captionPlaceholderLabel.hidden = captionTextView.text.characters.count != 0
    }
    func textViewDidChange(textView: UITextView) {
        captionPlaceholderLabel.hidden = textView.text.characters.count != 0
    }
    //    func textViewDidBeginEditing(textView: UITextView) {
    //        keyboardActiveView.hidden = false
    //        UIView.animateWithDuration(0.25, animations: {
    //            self.keyboardActiveView.backgroundColor =  UIColor(white: 0, alpha: 0.5)
    //        })
    //    }
    //    func textViewDidEndEditing(textView: UITextView) {
    //        UIView.animateWithDuration(0.4, animations: {
    //            self.keyboardActiveView.backgroundColor =  UIColor(white: 0, alpha: 0)
    //        })
    //        self.keyboardActiveView.hidden = true
    //    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        } else {
            return true
        }
    }
}

extension EditSpotViewController {
    func getColoredText(text:String) -> NSMutableAttributedString{
        let string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        let words:[NSString] = text.componentsSeparatedByString(" ")
        
        for word in words {
            if (word.hasPrefix("#")) {
                let range:NSRange = (string.string as NSString).rangeOfString(word as String)
                string.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGrayColor(), range: range)
                
                string.replaceCharactersInRange(range, withString: word as String)
            }
        }
        return string
    }
}