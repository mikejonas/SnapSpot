//
//  RecentsTableViewController.swift
//  PageMenuDemoTabbar
//
//  Created by Niklas Fahl on 1/9/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit

class RecentsTableViewController: UITableViewController {
    
    var parentNavigationController : UINavigationController?
        
    var namesArray : [String] = ["Kim White", "Kim White", "David Fletcher", "Anna Hunt", "Timothy Jones", "Timothy Jones", "Timothy Jones", "Lauren Richard", "Lauren Richard", "Juan Rodriguez"]
    var photoNameArray : [String] = ["barcelona.jpg", "barcelona.jpg", "barcelona.jpg", "barcelona.jpg", "barcelona.jpg", "barcelona.jpg", "barcelona.jpg", "barcelona.jpg", "barcelona.jpg", "barcelona.jpg"]
    var activityTypeArray : NSArray = [0, 1, 1, 0, 2, 1, 2, 0, 0, 2]
    var dateArray : NSArray = ["4:22 PM", "Wednesday", "Tuesday", "Sunday", "01/02/15", "12/31/14", "12/28/14", "12/24/14", "12/17/14", "12/14/14"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "RecentsTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentsTableViewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("\(self.title) page: viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.showsVerticalScrollIndicator = false
        super.viewDidAppear(animated)
        self.tableView.showsVerticalScrollIndicator = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 94.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var newVC : UIViewController = UIViewController()
        newVC.view.backgroundColor = UIColor.whiteColor()
        newVC.title = "Favorites"
        
        parentNavigationController!.pushViewController(newVC, animated: true)
    }
    
}
