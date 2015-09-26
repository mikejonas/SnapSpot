//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit
import GoogleMaps

public struct LocationBias {
    public let latitude: Double
    public let longitude: Double
    public let radius: Int
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    public var location: String {
        return "\(latitude),\(longitude)"
    }
}

public enum PlaceType: CustomStringConvertible {
    case All
    case Geocode
    case Address
    case Establishment
    case Regions
    case Cities
    
    public var description : String {
        switch self {
        case .All: return ""
        case .Geocode: return "geocode"
        case .Address: return "address"
        case .Establishment: return "establishment"
        case .Regions: return "(regions)"
        case .Cities: return "(cities)"
        }
    }
}

public class Place: NSObject {
    public let id: String
    public let desc: String
    public var apiKey: String?
    
    override public var description: String {
        get { return desc }
    }
    
    public init(id: String, description: String) {
        self.id = id
        self.desc = description
    }
    
    public convenience init(prediction: [String: AnyObject], apiKey: String?) {
        self.init(
            id: prediction["place_id"] as! String,
            description: prediction["description"] as! String
        )
        
        self.apiKey = apiKey
    }
    
    /**
    Call Google Place Details API to get detailed information for this place
    
    Requires that Place#apiKey be set
    
    - parameter result: Callback on successful completion with detailed place information
    */
    public func getDetails(result: PlaceDetails -> ()) {
        GooglePlaceDetailsRequest(place: self).request(result)
    }
}

public class PlaceDetails: CustomStringConvertible {
    public let name: String
    public let coordinates: CLLocationCoordinate2D?
    public var locality: String?
    public var subLocality: String?
    public var administrativeArea: String?
    public var country: String?
    public let fullAddress: String
    public let raw: [String: AnyObject]
    
    public init(json: [String: AnyObject]) {
        let result = json["result"] as! [String: AnyObject]
        let geometry = result["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: AnyObject]
        let addressComponents = result["address_components"] as! [AnyObject]
        
        for component in addressComponents {
            let componentType = component["types"] as! [String]
            if componentType.contains("locality") {
                self.locality = component["long_name"] as? String
            } else if componentType.contains("subLocality") {
                self.subLocality = component["subLocality"] as? String
            }
            else if componentType.contains("administrative_area_level_1") {
                self.administrativeArea = component["long_name"] as? String
            } else if componentType.contains("country") {
                self.country = component["long_name"] as? String
            }
        }
        self.name = result["name"] as! String
        self.fullAddress = result["formatted_address"] as! String
        self.raw = json
        self.coordinates = CLLocationCoordinate2DMake(location["lat"] as! Double, location["lng"] as! Double)
    }
    
    public var description: String {
        return "PlaceDetails: \(name) (\(coordinates), \(raw))"
    }
}

@objc public protocol GooglePlacesAutocompleteDelegate {
    optional func placesFound(places: [Place])
    optional func placeSelected(place: Place)
    optional func placeViewClosed()
    optional func placeSaved()
}

// MARK: - GooglePlacesAutocomplete
public class GooglePlacesAutocomplete: UINavigationController {
    public var gpaViewController: GooglePlacesAutocompleteContainer!
    public var closeButton: UIBarButtonItem!
    public var saveButton: UIBarButtonItem!
    
    // Proxy access to container navigationItem
    public override var navigationItem: UINavigationItem {
        get { return gpaViewController.navigationItem }
    }
    
    public var placeDelegate: GooglePlacesAutocompleteDelegate? {
        get { return gpaViewController.delegate }
        set { gpaViewController.delegate = newValue }
    }
    
    public var locationBias: LocationBias? {
        get { return gpaViewController.locationBias }
        set { gpaViewController.locationBias = newValue }
    }
    
    public convenience init(apiKey: String, placeType: PlaceType = .All) {
        let gpaViewController = GooglePlacesAutocompleteContainer(
            apiKey: apiKey,
            placeType: placeType
        )
        
        self.init(rootViewController: gpaViewController)
        self.gpaViewController = gpaViewController
        
        closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "close")
        closeButton.style = UIBarButtonItemStyle.Done
        
        saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "save")
        saveButton.style = UIBarButtonItemStyle.Done
        
        gpaViewController.navigationItem.leftBarButtonItem = closeButton
        gpaViewController.navigationItem.rightBarButtonItem = saveButton
        gpaViewController.navigationItem.title = "Enter Address"
    }
    
    func close() {
        placeDelegate?.placeViewClosed?()
    }
    
    func save() {
        placeDelegate?.placeSaved?()
    }
    
    public func reset() {
        gpaViewController.searchBar.text = ""
        gpaViewController.searchBar(gpaViewController.searchBar, textDidChange: "")
    }
}

// MARK: - GooglePlacesAutocompleteContainer
public class GooglePlacesAutocompleteContainer: UIViewController {
    @IBOutlet public weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: GMSMapView!

    //ADDED BY JONAS
    let locationUtil = LocationUtil()
    var spotAddressComponents:SpotAddressComponents?

    
    var delegate: GooglePlacesAutocompleteDelegate?
    var apiKey: String?
    var places = [Place]()
    var placeType: PlaceType = .All
    var locationBias: LocationBias?
    
    
    //ADDED BY JONAS
    var searchBarAddressText:String?
    var coordinates: CLLocationCoordinate2D?
    var marker = GMSMarker()
    
    convenience init(apiKey: String, placeType: PlaceType = .All) {
        let bundle = NSBundle(forClass: GooglePlacesAutocompleteContainer.self)
        
        self.init(nibName: "GooglePlacesAutocomplete", bundle: bundle)
        self.apiKey = apiKey
        self.placeType = placeType
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func viewWillLayoutSubviews() {
        topConstraint.constant = topLayoutGuide.length
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
        searchBar.becomeFirstResponder()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //MAPS
        setupMap(nil)
    }
    
    func setupMap(coordinates:CLLocationCoordinate2D?) {
        var camera: GMSCameraPosition
        if coordinates != nil { camera = GMSCameraPosition.cameraWithTarget(coordinates!, zoom: 18)}
        else { camera = GMSCameraPosition.cameraWithTarget(CLLocationCoordinate2DMake(38, -90), zoom: 2)}
        mapView.camera = camera
        mapView.mapType = kGMSTypeHybrid
        mapView.settings.myLocationButton = true
        mapView.delegate = self
    }
    
    func updateMap(coordinates:CLLocationCoordinate2D?) {
        if let coordinates = coordinates {
            let camera = GMSCameraPosition.cameraWithTarget(coordinates, zoom: 18)
            mapView.camera = camera
            marker.position = coordinates
            dropPin(coordinates)
        }
    }
    
    
    func dropPin(coordinates:CLLocationCoordinate2D?) {
        if let coordinates = coordinates {
            marker.position = coordinates
            marker.map = mapView
        }
    }
    
    func keyboardWasShown(notification: NSNotification) {
        if isViewLoaded() && view.window != nil {
            let info: Dictionary = notification.userInfo!
            let keyboardSize: CGSize = (info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size)!
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            
            tableView.contentInset = contentInsets;
            tableView.scrollIndicatorInsets = contentInsets;
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if isViewLoaded() && view.window != nil {
            self.tableView.contentInset = UIEdgeInsetsZero
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        }
    }
}


// MARK: - GooglePlacesAutocompleteContainer (GMSMapViewDelegate)
extension GooglePlacesAutocompleteContainer: GMSMapViewDelegate {
    public func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.searchBar.resignFirstResponder()
        self.tableView.hidden = true
        dropPin(coordinate)
        locationUtil.reverseGeoCodeCoordinate(coordinate, completion: { (updatedAddressComponents) -> Void in
            self.spotAddressComponents = updatedAddressComponents
            self.searchBar.text = self.spotAddressComponents!.fullAddress
            self.searchBarAddressText = self.spotAddressComponents!.fullAddress!
        })
    }
    public func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if self.searchBar.text == "" {
            self.searchBar.resignFirstResponder()
            self.tableView.hidden = true
            self.searchBar.text = searchBarAddressText
        }
    }
}


// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Get the corresponding candy from our candies array
        let place = self.places[indexPath.row]
        
        // Configure the cell
        cell.textLabel!.text = place.description
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.placeSelected?(self.places[indexPath.row])
        searchBar.text = self.places[indexPath.row].desc
        searchBarAddressText = searchBar.text
        searchBar.resignFirstResponder()
        tableView.hidden = true
        self.places[indexPath.row].getDetails { details in
            self.spotAddressComponents = SpotAddressComponents(coordinates: details.coordinates, locality: details.locality, subLocality: details.subLocality, administrativeArea: details.administrativeArea, country: details.country, fullAddress: details.fullAddress)
            self.dropPin(self.spotAddressComponents!.coordinates)
            self.setupMap(self.spotAddressComponents!.coordinates)
        }
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.places = []
            tableView.hidden = true
            resignFirstResponder()
        } else {
            getPlaces(searchText)
        }
    }
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        tableView.hidden = true
        searchBar.resignFirstResponder()
        searchBar.text = searchBarAddressText
    }
    
    public func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        if (searchBar.text != "") {
            getPlaces(searchBar.text!)
        }
    }
    
    public func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    /**
    Call the Google Places API and update the view with results.
    
    - parameter searchString: The search query
    */
    private func getPlaces(searchString: String) {
        var params = [
            "input": searchString,
            "types": placeType.description,
            "key": apiKey ?? ""
        ]
        
        if let bias = locationBias {
            params["location"] = bias.location
            params["radius"] = bias.radius.description
        }
        
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: params
            ) { json in
                if let predictions = json["predictions"] as? Array<[String: AnyObject]> {
                    self.places = predictions.map { (prediction: [String: AnyObject]) -> Place in
                        return Place(prediction: prediction, apiKey: self.apiKey)
                    }
                    
                    self.tableView.reloadData()
                    self.tableView.hidden = false
                    self.delegate?.placesFound?(self.places)
                }
        }
    }
}

// MARK: - GooglePlaceDetailsRequest
class GooglePlaceDetailsRequest {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    func request(result: PlaceDetails -> ()) {
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/details/json",
            params: [
                "placeid": place.id,
                "key": place.apiKey ?? ""
            ]
            ) { json in
                result(PlaceDetails(json: json as! [String: AnyObject]))
        }
    }
}

// MARK: - GooglePlacesRequestHelpers
class GooglePlacesRequestHelpers {
    /**
    Build a query string from a dictionary
    
    - parameter parameters: Dictionary of query string parameters
    - returns: The properly escaped query string
    */
    private class func query(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sort(<) {
            let value: AnyObject! = parameters[key]
            components += [(escape(key), escape("\(value)"))]
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joinWithSeparator("&")
    }
    
    private class func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
    private class func doRequest(url: String, params: [String: String], success: NSDictionary -> ()) {
        let request = NSMutableURLRequest(
            URL: NSURL(string: "\(url)?\(query(params))")!
        )
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.handleResponse(data, response: response as? NSHTTPURLResponse, error: error, success: success)
        }
        
        task.resume()
    }
    
    private class func handleResponse(data: NSData!, response: NSHTTPURLResponse!, error: NSError!, success: NSDictionary -> ()) {
        if let error = error {
            print("GooglePlaces Error: \(error.localizedDescription)")
            return
        }
        
        if response == nil {
            print("GooglePlaces Error: No response from API")
            return
        }
        
        if response.statusCode != 200 {
            print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
            return
        }
        
        guard let response = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) else {
            print("GooglePlaces Error: \(error.localizedDescription)")
            return
        }
        
        guard let json = response as? NSDictionary else {
            print("Not a dictionary")
            return
        }
        
        guard let status = json["status"] as? String where status == "OK" else {
            print("GooglePlaces API Error")
            return
        }
        
        // Perform table updates on UI thread
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            success(json)
        })
    }
}