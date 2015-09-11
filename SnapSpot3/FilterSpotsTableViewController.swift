//
//  FilterSpotsTableViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 9/5/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class FilterSpotsTableViewController: UITableViewController {
    
    var sortedHashtagsArr:[(String, Int)] = []

    
    override func viewWillAppear(animated: Bool) {
        var query = PFQuery(className:"Spot")
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            var hashtagArrays:[[String]] = []
            if let spots = objects {
                for spot in spots {
                    hashtagArrays.append(spot["hashTags"] as! [String])
                }
                self.sortedHashtagsArr = self.countAndsortArrays(hashtagArrays)
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.setEditing(true, animated: true)
        
        
        
        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func leftBarButtonItemTapped(sender: UIBarButtonItem) {
        pageController.goToPreviousVC()
    }
    
    
    func countAndsortArrays(hashtagArrays:[[String]]) -> [(String, Int)] {
        var arr:[(String,Int)] = []
        var sortedHashtagDict = [String:Int]()

        for item in hashtagArrays {
            for hashTag in item {
                if (sortedHashtagDict[hashTag] != nil) {
                    sortedHashtagDict[hashTag] = sortedHashtagDict[hashTag]! + 1
                } else {
                    sortedHashtagDict[hashTag] = 1
                }
            }
        }
        
        arr = sorted(sortedHashtagDict, { t1, t2 in
            return t1.0 < t2.0
        })
        
        return arr
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedHashtagsArr.count
    }
    
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        let hashtag:(String,Int) = self.sortedHashtagsArr[indexPath.row]
        cell.textLabel?.text = "#\(hashtag.0)"
        cell.detailTextLabel?.text = "\(hashtag.1)"

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cellText = cell.textLabel?.text {
            if contains(Globals.variables.filterSpotsHashtag, dropFirst(cellText)) {
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            } else {
                cell.selected = false
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedHashTag = self.sortedHashtagsArr[indexPath.row].0
        Globals.variables.filterSpotsHashtag.append(selectedHashTag)
        find(Globals.variables.filterSpotsHashtag, selectedHashTag)!
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedHashTag = self.sortedHashtagsArr[indexPath.row].0
        let itemToRemove = find(Globals.variables.filterSpotsHashtag, selectedHashTag)!
        Globals.variables.filterSpotsHashtag.removeAtIndex(itemToRemove)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
