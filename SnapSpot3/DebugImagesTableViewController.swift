//
//  DebugImagesTableViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 10/1/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import UIKit

class DebugImagesTableViewController: UITableViewController {

    struct imageComponents {
        var image:UIImage?
        var size:String?
        var dimensions:String?
    }
    
    var imageComponentArr:[imageComponents] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageComponentArr = convertUrlToImageComponents(getAllImageURLS())
        self.tableView.reloadData()
    }


    func getAllImageURLS() -> [NSURL] {
        let fileManager = NSFileManager.defaultManager()
        var files:[NSURL] = []
        // We need just to get the documents folder url
        let documentsUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        do {
            // if you want to filter the directory contents you can do like this:
            if let directoryUrls = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) {
                files = directoryUrls
            }
        }
        return files
    }
    
    func convertUrlToImageComponents(nsurls:[NSURL]) -> [imageComponents] {
        var imageComponentsArr:[imageComponents] = []
        for url in nsurls {
            var components = imageComponents()
            if let data = NSData(contentsOfURL: url) {
                components.image = UIImage(data: data)
                components.dimensions = "\(UIImage(data:data)!.size)"
                components.size = "\(data.length / 1024)kb"
            }
            imageComponentsArr.append(components)
        }
        return imageComponentsArr
    }
    
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return imageComponentArr.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:DebugImagesTableViewCell = tableView.dequeueReusableCellWithIdentifier("DebugImagesTableViewCell", forIndexPath: indexPath) as! DebugImagesTableViewCell
        
        if let photo = imageComponentArr[indexPath.row].image {
            cell.photo.image = photo
            print(photo)
        }
        if let dimensions = imageComponentArr[indexPath.row].dimensions {
            cell.dimensionsLabel.text = dimensions
        }
        if let size = imageComponentArr[indexPath.row].size {
            cell.sizeLabel.text = size
        }
        
        // Configure the cell...

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
