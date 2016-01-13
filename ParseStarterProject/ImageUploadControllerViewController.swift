//
//  ImageUploadControllerViewController.swift
//  Clonagram
//
//  Created by Julian Nicholls on 13/01/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ImageUploadControllerViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var uploadButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        uploadButton.enabled = false
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    @IBAction func selectPressed(sender: AnyObject) {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true

        self.presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)

        self.imageView.image = image

        uploadButton.enabled = true
    }

    @IBAction func uploadPressed(sender: AnyObject) {
        let imageData = UIImagePNGRepresentation(self.imageView.image!)
        let file = PFFile(name: "uploaded.png", data: imageData!)
        let image = PFObject(className: "Image")

        var errMsg = "Try again later"

        image.setValue(PFUser.currentUser()?.objectId, forKey: "userId")
        image.setValue(file, forKey: "Image")
        image.setValue(caption.text, forKey: "caption")

        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .Gray

        view.addSubview(indicator)

        indicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        image.saveInBackgroundWithBlock {
            (success, error) -> Void in

            self.indicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()

            if error == nil {
                self.imageView.image = UIImage(named: "placeholder.png")
                self.caption.text = ""
                self.displayAlert("The image was uploaded successfully", title: "Upload successful")
            }
            else {
                if let errorStr = error?.userInfo["error"] as? String {
                    errMsg = errorStr
                }

                self.displayAlert(errMsg, title: "Problem with posting")
            }
        }
    }

    func displayAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            (action) -> Void in

            self.dismissViewControllerAnimated(true, completion: nil)
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }






    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
