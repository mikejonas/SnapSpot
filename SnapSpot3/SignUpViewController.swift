//
//  SignUpViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 10/13/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonTapped(sender: UIButton) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
    
        createUser(username!, password: password!, email: email!)
    }

    func validateUsername() {
        
    }
    func validatePassword() {
        
    }
    func validateEmail() {
        
    }
    
    func createUser(username:String, password:String, email:String) {
        let ref = Firebase(url: "https://snapspot.firebaseio.com")
        let usersRef = ref.childByAppendingPath("users")
        ref.createUser(email , password: password,
            withValueCompletionBlock: { error, result in
                if error != nil {
                    print("ERROR \(error)")
                } else {
                    if let uid = result["uid"] as? String {
                        print("Successfully created user account with uid: \(uid)")
                        print("Result: \(result)")
                        usersRef.childByAppendingPath(uid).setValue(["username": username, "email": email])
                    }
                }
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
