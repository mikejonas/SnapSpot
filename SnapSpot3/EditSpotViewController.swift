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
    func spotSaved()
}

class EditSpotViewController: UIViewController {
    
    let addImageCameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddImageCameraViewController") as! AddImageCameraViewController
    
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: "AIzaSyB-0-hv2zKDeYl17vRTaDOPKhuQiZnsXmo",
        placeType: .All
    )
    
    var coordinates: CLLocationCoordinate2D?
    var spotAddressComponents:AddressComponents?
    var marker = GMSMarker()
    var topString = ""
    var bottomString = ""
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    @IBOutlet weak var keyboardActiveView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var mapViewGroupView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    
    var imageArray: [UIImage] = []
    @IBOutlet weak var photoThumbnail0: UIImageView!
    @IBOutlet weak var photoThumbnail1: UIImageView!
    @IBOutlet weak var photoThumbnail2: UIImageView!
    var imageViewArray: [UIImageView]!
    var deleteImageButton = UIButton()

    var delegate: EditSpotViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        //TEXT View
        setupTextView()
        setupTextViewPlaceholder()

        
        //IMAGE TAPPED
        imageViewArray  = [photoThumbnail0, photoThumbnail1, photoThumbnail2]
        for imageView in imageViewArray {
            let tapImage = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
            imageView.addGestureRecognizer(tapImage)
            imageView.userInteractionEnabled = true
        }

        //MAP
        let tap = UITapGestureRecognizer(target: self, action: Selector("mapViewGroupviewTapped"))
        mapViewGroupView.addGestureRecognizer(tap)
        setupMap(coordinates)
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
        }
        clearView()
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if (delegate != nil) {
            delegate?.spotSaved()
            clearView()
        }
    }
    
    @IBAction func testButtonTapped(sender: AnyObject) {
        var testString = getColoredText(descriptionTextView.text)
        descriptionTextView.attributedText = testString
        descriptionTextView.font =  UIFont(name: descriptionTextView.font.fontName, size: 14)
    }
    
    func clearView() {
        imageArray = []
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
        println(imageArray.count)
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


//Setup Map functions
extension EditSpotViewController {
    func setupMap(coordinates:CLLocationCoordinate2D?) {
        mapView.mapType = kGMSTypeHybrid
        mapView.settings.setAllGesturesEnabled(false)
        if let coordinates = coordinates {
            let camera = GMSCameraPosition.cameraWithTarget(coordinates, zoom: 18)
            mapView.camera = camera
            marker.position = coordinates
            marker.map = mapView
            marker.tappable = false
            marker.title = topString
            marker.snippet = bottomString
            mapView.selectedMarker = marker
            println(coordinates.latitude)
            println(coordinates.longitude)
        } else {
            let coordinates = CLLocationCoordinate2DMake(38, -90)
            let camera = GMSCameraPosition.cameraWithTarget(coordinates, zoom: 2)
            mapView.camera = camera
        }
    }
    
    func mapViewGroupviewTapped() {
        presentViewController(gpaViewController, animated: true, completion: nil)
    }
}

extension EditSpotViewController: GooglePlacesAutocompleteDelegate {
    
    func placeNotSaved() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func placeSaved() {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            self.spotAddressComponents = self.gpaViewController.gpaViewController.spotAddressComponents
            var (topLine, bottomLine) = self.addressFormatter(self.spotAddressComponents!)
            self.setupMap(self.spotAddressComponents?.coordinates)
        })
    }
    
    func addressFormatter(address:AddressComponents) -> (String, String) {
        var addressString = address.fullAddress!
        if let locality = address.locality {
            
            if let localityPosition = addressString.rangeOfString(locality, options: .BackwardsSearch)?.startIndex {
                topString = addressString.substringToIndex(localityPosition.predecessor())
                bottomString = addressString.substringFromIndex(localityPosition)
            }
        } else {
            bottomString = addressString
        }
        return (topString, bottomString)
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
        println("ADSF")
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
            return false;
        } else {
            return true
        }
    }
}


