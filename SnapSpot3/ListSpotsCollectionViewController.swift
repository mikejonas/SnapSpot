//
//  ListSpotsCollectionViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/27/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit


class ListSpotsCollectionViewController: UICollectionViewController {

    let reuseIdentifier = "SpotCollectionCell"

    var parentNavigationController : UINavigationController?
    var dateFormatter = NSDateFormatter()
    var spots:[SpotComponents] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        print("COLLECTION VIEW WILL APPEAR")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("COLLECTION VIEW DID LOAD")
    
        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = UIColor.whiteColor()
    }
    
    func collectionViewTestReloadData() {
        let query = PFQuery(className:"Spot")
        query.fromLocalDatastore()
        query.orderByDescending("date")
        if Globals.variables.filterSpotsHashtag.count > 0 {
            query.whereKey("hashTags", containedIn: Globals.variables.filterSpotsHashtag)
        }
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let spots = objects {
                self.spots = []
                for spot in spots {
                    print(spot)
                    self.spots.append(convertParseObjectToSpotComponents(spot))
                }
            }
            self.collectionView!.reloadData()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewSpotSegue" {
            let destinationVC = segue.destinationViewController as! ViewSpotViewController
            let cell = sender as! UICollectionViewCell

            let indexPath = self.collectionView!.indexPathForCell(cell)
            destinationVC.spotComponents = self.spots[indexPath!.row]
        }
        
    }

    // Full Screen Shot function. Hope this will work well in swift.
    
    func screenShot() -> UIImage {
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!) //??? added the !
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenShot
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return spots.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:SpotCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SpotCollectionCell

        let city = spots[indexPath.row].addressComponents!.locality
        let city2 = spots[indexPath.row].addressComponents!.subLocality
        
        if city != nil {
            cell.locationLabel.text = city
        } else if city2 != nil {
            cell.locationLabel.text = city2
        }
        
        if let imageFileNames = spots[indexPath.row].localImagePaths {
            let imageArray = retrieveImagesLocally(imageFileNames)
            if imageArray.count > 0 {
                cell.imageThumbnail.image = imageArray[0]
            }
        }
        
        if let timeStamp = spots[indexPath.row].date {
            dateFormatter.dateFormat = "MMM dd"
            let monthDay = dateFormatter.stringFromDate(timeStamp).componentsSeparatedByString(" ")
            
            cell.monthLabel.text = monthDay[0]
            cell.dayLabel.text = monthDay[1]
        }

        // Configure the cell
        return cell
    }
    
    

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            performSegueWithIdentifier("ViewSpotSegue", sender: cell)
        } else {
            print("Error indexPath is not on screen: this should never happen.")
        }
        
    }
    
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
