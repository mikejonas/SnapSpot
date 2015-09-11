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
}

class EditSpotViewController: UIViewController {
    let addImageCameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddImageCameraViewController") as! AddImageCameraViewController
    
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: "AIzaSyB-0-hv2zKDeYl17vRTaDOPKhuQiZnsXmo",
        placeType: .All
    )
    let locationUtil = LocationUtil()
    
    var spotComponents = SpotComponents()
    var spotAddressComponents:SpotAddressComponents?
    var marker = GMSMarker()
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var keyboardActiveView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    var placeholderLabel : UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var photoThumbnail0: UIImageView!
    @IBOutlet weak var photoThumbnail1: UIImageView!
    @IBOutlet weak var photoThumbnail2: UIImageView!
    var imageArray: [UIImage] = []
    var imageViewArray: [UIImageView]!
    var deleteImageButton = UIButton()
    
    var delegate: EditSpotViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupTextView()
        setupTextViewPlaceholder()
        setupImages()
        setupMap()
                
        addImageCameraVC.delegate = self
        gpaViewController.placeDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        navigationBar.frame=CGRectMake(0, 0, self.view.frame.size.width, 64)  // Here you can set you Width and Height for your navBar
    }
    
    // If I want to resignfirstresponder for touching anywhere
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
        deleteImageButton.hidden = true
    }
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        if (delegate != nil) {
            delegate?.spotClosed()
            resetView()
        }
        
    }
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        
        //Caption
        spotComponents.caption = descriptionTextView.text
        spotComponents.date = NSDate()
        
        //HashTags
        descriptionTextView.extractHashTags { extractedHashtags in
            self.spotComponents.hashTags = extractedHashtags
        }
        
        //Image
        spotComponents.images = imageArray
        
        //Address components
        spotComponents.addressComponents = spotAddressComponents
        
        if (delegate != nil) {
            println(spotComponents.description)
            delegate?.spotSaved(spotComponents)
            resetView()
        }
    }
    @IBAction func testButtonTapped(sender: AnyObject) {
        
        descriptionTextView.extractHashTags { extractedHashtags in
            println(extractedHashtags)
        }
        
        
//        locationUtil.getCoordinatesWithDelayUpTo(seconds: 5) {(cooordinates) -> Void in
//            self.updateMapAndReverseGeocode(cooordinates)
//        }
        if let spotAddressComponents = spotAddressComponents {
            println(spotAddressComponents.description)
        }
    }
    func resetView() { //clear
        imageArray = []
        spotAddressComponents = nil
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
    func setupImages() {
        imageViewArray  = [photoThumbnail0, photoThumbnail1, photoThumbnail2]
        for imageView in imageViewArray {
            let tapImage = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
            imageView.addGestureRecognizer(tapImage)
            imageView.userInteractionEnabled = true
        }
    }
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
    }
    func imageTapped(sender:AnyObject) {
        let senderImageView = sender.view as! UIImageView
        
        if senderImageView.image == nil {
            presentViewController(addImageCameraVC, animated: true, completion: nil)
        } else {
            for imageView in imageViewArray {
                if senderImageView == imageView {
                    addDeleteButton(imageView)
                }
            }
        }
    }
    func addDeleteButton(photoThumbnail:UIImageView) {
            deleteImageButton.frame = CGRectMake(photoThumbnail.bounds.origin.x - 10, photoThumbnail.bounds.origin.y - 10, 40, 40)
            deleteImageButton.setImage(UIImage(named: "DeleteImage"), forState: .Normal)
            photoThumbnail.addSubview(deleteImageButton)
            deleteImageButton.hidden = false
            deleteImageButton.addTarget(self, action: "deleteButtonTapped:", forControlEvents: .TouchUpInside)
    }
    func deleteButtonTapped(sender:UIButton) {
        if let imageIndex = find(imageViewArray, sender.superview as! UIImageView) {
            removeImage(imageIndex)
            sender.hidden = true
        }
    }
}

//Setup Map functions
extension EditSpotViewController {
    func setupMap() {
        let tap = UITapGestureRecognizer(target: self, action: Selector("mapViewTapped"))
        mapView.addGestureRecognizer(tap)
        mapView.mapType = kGMSTypeHybrid
        mapView.settings.setAllGesturesEnabled(false)
        marker.tappable = false
        updateMap(spotAddressComponents?.coordinates)
    }
    func updateMap(coordinates:CLLocationCoordinate2D?) {
        if let coordinates = coordinates {
            
            self.spotAddressComponents?.coordinates = coordinates
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
    func updateMapAndReverseGeocode(coordinates:CLLocationCoordinate2D?) {
        updateMap(coordinates)
        if let coordinates = coordinates {
            locationUtil.reverseGeoCodeCoordinate(coordinates, completion: { (updatedAddressComponents) -> Void in
                self.spotAddressComponents = updatedAddressComponents
                self.updateMarkerModal(self.spotAddressComponents!)
            })
        }
    }
    func mapViewTapped() {
     //REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR REFACTOR
        presentViewController(gpaViewController, animated: true) { () -> Void in
            self.gpaViewController.gpaViewController.updateMap(self.spotAddressComponents?.coordinates)
            self.gpaViewController.gpaViewController.spotAddressComponents = self.spotAddressComponents
            self.gpaViewController.gpaViewController.searchBar.text = self.spotAddressComponents?.fullAddress
            self.gpaViewController.gpaViewController.searchBarAddressText = self.spotAddressComponents?.fullAddress
        }
    }
    
    func updateMarkerModal(address:SpotAddressComponents) -> () {
        var addressString = address.fullAddress!
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

extension EditSpotViewController: GooglePlacesAutocompleteDelegate {
    func placeNotSaved() {
        dismissViewControllerAnimated(true, completion: nil)
        if self.spotAddressComponents != nil {
            self.updateMarkerModal(self.spotAddressComponents!)
        }
    }
    func placeSaved() {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            self.spotAddressComponents = self.gpaViewController.gpaViewController.spotAddressComponents
            self.updateMap(self.spotAddressComponents?.coordinates)
            if self.spotAddressComponents != nil {
                self.updateMarkerModal(self.spotAddressComponents!)
            }
        })
    }
}

extension EditSpotViewController: UITextViewDelegate {
    func setupTextView() {
        descriptionTextView.clipsToBounds = true
        descriptionTextView.layer.cornerRadius = 4
        descriptionTextView.contentInset = UIEdgeInsetsMake(-2,0,-2,0)
        descriptionTextView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.35).CGColor
        descriptionTextView.layer.borderWidth = 1
    }

    func setupTextViewPlaceholder() {
        descriptionTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Description / #tags"
        placeholderLabel.font = descriptionTextView.font
        placeholderLabel.sizeToFit()
        descriptionTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, descriptionTextView.font.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = count(descriptionTextView.text) != 0
    }
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = count(textView.text) != 0
    }
    func textViewDidBeginEditing(textView: UITextView) {
        keyboardActiveView.hidden = false
        UIView.animateWithDuration(0.25, animations: {
            self.keyboardActiveView.backgroundColor =  UIColor(white: 0, alpha: 0.5)
        })
    }
    func textViewDidEndEditing(textView: UITextView) {
        UIView.animateWithDuration(0.4, animations: {
            self.keyboardActiveView.backgroundColor =  UIColor(white: 0, alpha: 0)
        })
        self.keyboardActiveView.hidden = true
    }
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
        var string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        var words:[NSString] = text.componentsSeparatedByString(" ")
        
        for (var word:NSString) in words {
            if (word.hasPrefix("#")) {
                var range:NSRange = (string.string as NSString).rangeOfString(word as String)
                string.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGrayColor(), range: range)
                
                string.replaceCharactersInRange(range, withString: word as String)
            }
        }
        return string
    }
}