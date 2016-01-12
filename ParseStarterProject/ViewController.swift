/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    var indicator = UIActivityIndicatorView()

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var registered: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func mainPressed(sender: AnyObject) {
        let title = isSetForSignup() ? "Error signing up" : "Error logging in"

        if username.text != "" && password.text != "" {
            displaySpinner()

            var errMsg = "Try again later"

            if isSetForSignup() {       // Sign up
                let user = PFUser()

                user.username = username.text
                user.password = password.text

                user.signUpInBackgroundWithBlock({
                    (success, error) -> Void in

                    self.indicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()

                    if error == nil {
                        // Signup successful, for now
                    }
                    else {
                        if let errorStr = error?.userInfo["error"] as? String {
                            errMsg = errorStr
                        }

                        self.displayAlert(errMsg, title: title)
                    }
                })
            }
            else {      // Log in
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: {
                    (user, error) -> Void in

                    self.indicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()

                    if error == nil {
                        // logged in for now
                    }
                    else {
                        if let errorStr = error?.userInfo["error"] as? String {
                            errMsg = errorStr
                        }

                        self.displayAlert(errMsg, title: title)
                    }
                })
            }
        }
        else {
            displayAlert("Please enter a user name and password", title: title)
        }
    }

    @IBAction func secondPressed(sender: AnyObject) {
        if isSetForSignup() {
            secondButton.setTitle("Sign up", forState: .Normal)
            mainButton.setTitle("Log in", forState: .Normal)
            registered.text = "Not registered?"
        }
        else {
            secondButton.setTitle("Log in", forState: .Normal)
            mainButton.setTitle("Sign up", forState: .Normal)
            registered.text = "Already registered?"
        }
    }

    func displayAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }

    func displaySpinner() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .Gray

        self.view.addSubview(indicator)

        indicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    func isSetForSignup() -> Bool {
        return mainButton.currentTitle == "Sign up"
    }
}
