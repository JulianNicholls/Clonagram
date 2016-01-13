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


    @IBAction func selectPressed(sender: AnyObject) {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true

        self.presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)

        imageView.image = image

        uploadButton.enabled = true
    }

    @IBAction func uploadPressed(sender: AnyObject) {
        var errMsg = "Try again later"

        indicator = UIActivityIndicatorView(frame: self.view.frame)
        indicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        indicator.center = imageView.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .Gray

        view.addSubview(indicator)

        indicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        let imageData = UIImagePNGRepresentation(self.imageView.image!)
        let imageFile = PFFile(name: "uploaded.png", data: imageData!)
        let image     = PFObject(className: "Image")

        image["userId"]  = PFUser.currentUser()?.objectId!
        image["file"]    = imageFile
        image["caption"] = caption.text

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
