//
//  SettingsTableViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/26/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit


class SettingsTableViewController: UITableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    let tableSections = [3, 3, 2]
    var logInViewController: PFLogInViewController! = PFLogInViewController()
    var signUpViewController: PFSignUpViewController! = PFSignUpViewController()
    
    
    
    @IBOutlet weak var logInCell: UITableViewCell!
    @IBOutlet weak var syncSwitch: UISwitch!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshTable()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33.0 / 255.0, green: 33.0 / 255.0, blue: 33.0 / 255.0, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Login view controller
        self.logInViewController.fields = [PFLogInFields.UsernameAndPassword, PFLogInFields.LogInButton, PFLogInFields.SignUpButton, PFLogInFields.PasswordForgotten, PFLogInFields.DismissButton]
    
        let logInLogoTitle = UILabel()
        logInLogoTitle.text = "Logo"
        logInLogoTitle.textColor = UIColor.darkGrayColor()
        logInLogoTitle.font = UIFont(name: "HelveticaNeue-Light", size: 40)
    
        self.logInViewController.logInView?.logo = logInLogoTitle
        self.logInViewController.delegate = self
        
        // Sign up view controller
        let signUpLogoTitle = UILabel()
        signUpLogoTitle.text = "LOGO"
        signUpLogoTitle.textColor = UIColor.darkGrayColor()
        signUpLogoTitle.font = UIFont(name: "HelveticaNeue-Light", size: 40)

        self.signUpViewController.signUpView?.logo = signUpLogoTitle
        self.signUpViewController.delegate = self
        self.logInViewController.signUpController = self.signUpViewController
        
    }
    
    
    @IBAction func syncSwitchTapped(sender: UISwitch) {
        if (syncSwitch.on && PFUser.currentUser() == nil) {
            //LOGGED OUT USERS CANNOT SYNC!
            showSignUpAlert("You need a SnapSpot account in order to sync")
        } else if (!syncSwitch.on && PFUser.currentUser() == nil) {
            //This should never occur
            print("??? HMMMM")
        } else if (syncSwitch.on && PFUser.currentUser() != nil) {
            //Set sync to true
            Globals.constants.defaults.setBool(true, forKey: "isSyncSet")
            self.refreshTable()
        } else if (!syncSwitch.on && PFUser.currentUser() != nil) {
            //Set sync to false
            Globals.constants.defaults.setBool(false, forKey: "isSyncSet")
            self.refreshTable()
        }
    }
    
    @IBAction func rightBarButtonItemTapped(sender: AnyObject) {
        pageController.goToNextVC()
    }
    
    func refreshTable() {
        if let user = PFUser.currentUser()?.username{
            logInCell.textLabel?.text = "\(user)"
            logInCell.detailTextLabel?.text = nil
            if Globals.constants.defaults.boolForKey("isSyncSet") == true {
                self.syncSwitch.setOn(true, animated: false)
            } else {
                self.syncSwitch.setOn(false, animated: false)
            }
        } else {
            logInCell.textLabel?.text = "SnapSpot"
            logInCell.detailTextLabel?.text = "Sign in"
        }
    }
    
    
    func showSignUpAlert(message:String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        let createAccountAction = UIAlertAction(title: "Create account", style: .Default) { (action) in
                self.presentViewController(self.signUpViewController, animated: true, completion: nil)
        }
        alertController.addAction(createAccountAction)
        
        let signInAction = UIAlertAction(title: "Sign in", style: .Default) { (action) in
                    self.presentViewController(self.logInViewController, animated: true, completion: nil)
        }
        alertController.addAction(signInAction)
        
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
                PFUser.currentUser() == nil ? showSignUpAlert(nil) : self.performSegueWithIdentifier("toAccountSettings", sender: self)
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

    
    // Mark: Parse Login
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if (!username.isEmpty) || !password.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        print("Failed to login")
    }
    
    
    
    // Mark: Parse Sign Up
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("toAccountSettings", sender: self)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("failed to sign up...")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        print("User dismissed sign up.")
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
