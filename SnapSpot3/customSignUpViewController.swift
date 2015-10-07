//
//  customSignUpViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 10/6/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import UIKit

class customSignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.actInd)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Actions
    
    @IBAction func signUpButtonTapped(sender: UIButton) {
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        
        if (username?.utf16.count < 4 || password?.utf16.count < 5) {
            let alert = UIAlertView(title: "Invalid", message: "Username must be greater then 4 and Password must be greater then 5.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else if (email?.utf16.count < 8) {
            let alert = UIAlertView(title: "Invalid", message: "Please enter a valid email.", delegate: self, cancelButtonTitle: "ok")
            alert.show()
        } else {
            self.actInd.startAnimating()
            let newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = email

            newUser.signUpInBackgroundWithBlock({ (success, error) -> Void in
                self.actInd.stopAnimating()
                if ((error) != nil) {
                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "ok")
                    alert.show()
                } else {
                    let alert = UIAlertView(title: "Success", message: "Signed Up", delegate: self, cancelButtonTitle: "ok")
                    alert.show()
                }
            })
        }
        
    }

}
