//
//  ListSpotsCollectionViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/27/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

let reuseIdentifier = "SpotGridCell"

class ListSpotsCollectionViewController: UICollectionViewController {

    var dateFormatter: NSDateFormatter!
    var spots:[PFObject] = []
    
    override func viewWillAppear(animated: Bool) {
        var query = PFQuery(className:"Spot")
        query.fromLocalDatastore()
        query.orderByDescending("date")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let spots = objects {
                self.spots = spots as! [PFObject]
            }
            self.collectionView!.reloadData()
            println(self.spots[2])
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        dateFormatter = NSDateFormatter()
        collectionView?.backgroundColor = UIColor.whiteColor()
        
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
            let spotObject = self.spots[indexPath!.row]
            destinationVC.spotObject = spotObject
        }
        
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SpotCollectionCell

        let imageFileNames = spots[indexPath.row]["localImagePaths"] as? [String]
        let images = retrieveImageLocally(imageFileNames!)
        cell.imageThumbnail.image = images[0]
        
        let timeStamp = spots[indexPath.row]["date"] as! NSDate
        dateFormatter.dateFormat = "MMM dd"
        let monthDay = split( dateFormatter.stringFromDate(timeStamp) ) {$0 == " "}
        cell.monthLabel.text = monthDay[0]
        cell.dayLabel.text = monthDay[1]

        if let city = spots[indexPath.row]["locality"] as? String {
            cell.locationLabel.text = city
        }
        // Configure the cell
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ViewSpotSegue", sender: self)
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
