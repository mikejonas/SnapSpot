//
//  SettingsTableViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/26/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit


class SettingsTableViewController: UITableViewController {
    
    let tableSections = [3, 1, 2, 2]
    
    let signUpVc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
    
    @IBOutlet weak var logInCell: UITableViewCell!
    @IBOutlet weak var syncSwitch: UISwitch!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshTable()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33.0 / 255.0, green: 33.0 / 255.0, blue: 33.0 / 255.0, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func syncSwitchTapped(sender: UISwitch) {
        if (syncSwitch.on /*&& PFUser.currentUser() == nil*/) {
            //LOGGED OUT USERS CANNOT SYNC!
            showSignUpAlert("You need a SnapSpot account in order to sync")
        } else if (!syncSwitch.on /*&& PFUser.currentUser() == nil*/) {
            //This should never occur
            print("??? HMMMM")
        } else if (syncSwitch.on /*&& PFUser.currentUser() != nil*/) {
            //Set sync to true
            Globals.constants.defaults.setBool(true, forKey: "isSyncSet")
            self.refreshTable()
        } else if (!syncSwitch.on /*&& PFUser.currentUser() != nil*/) {
            //Set sync to false
            Globals.constants.defaults.setBool(false, forKey: "isSyncSet")
            self.refreshTable()
        }
    }
    
    @IBAction func rightBarButtonItemTapped(sender: AnyObject) {
        pageController.goToNextVC()
    }
    
    func refreshTable() {
//        if let user = PFUser.currentUser()?.username{
//            logInCell.textLabel?.text = "\(user)"
//            logInCell.detailTextLabel?.text = nil
//            if Globals.constants.defaults.boolForKey("isSyncSet") == true {
//                self.syncSwitch.setOn(true, animated: false)
//            } else {
//                self.syncSwitch.setOn(false, animated: false)
//            }
//        } else {
//            logInCell.textLabel?.text = "SnapSpot"
//            logInCell.detailTextLabel?.text = "Sign in"
//        }
    }
    
    
    func showSignUpAlert(message:String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        let createAccountAction = UIAlertAction(title: "Create account", style: .Default) { (action) in
                self.presentViewController(self.signUpVc, animated: true, completion: nil)
        }
        alertController.addAction(createAccountAction)
        
//        let signInAction = UIAlertAction(title: "Sign in", style: .Default) { (action) in
//            self.presentViewController(self.logInViewController, animated: true, completion: nil)
//        }
//        alertController.addAction(signInAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            self.syncSwitch.setOn(false, animated: true)
            if let indexPaths = self.tableView.indexPathsForSelectedRows {
                for indexPath in indexPaths {
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            }

        }
        alertController.addAction(cancelAction)
  
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSections[section]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0:
                print("check current user")
//                PFUser.currentUser() == nil ? showSignUpAlert(nil) : self.performSegueWithIdentifier("toAccountSettings", sender: self)
            default: break
            }
        default:
            print("This should never be displayed!")
        }
    }

    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("signincell", forIndexPath: indexPath)
//        
//        // Configure the cell...
//
//        return cell
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
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
