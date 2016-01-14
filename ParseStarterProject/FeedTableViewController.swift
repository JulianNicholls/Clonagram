//
//  FeedTableViewController.swift
//  Clonagram
//
//  Created by Julian Nicholls on 13/01/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {

    var images   = [NSDictionary]()
    var userlist = Dictionary<String, String>()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserNames()
        loadFollowedUsers()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! TableImageCell

        let cur = images[indexPath.row]
        let file = cur["file"] as! PFFile

        file.getDataInBackgroundWithBlock {
            (data, error) -> Void in

            if let image = UIImage(data: data!) {
                cell.postedImage.image = image
            }
        }

        cell.postedImage.image = UIImage(named: "camera.png")
        cell.caption.text = cur["caption"] as? String
        cell.username.text = cur["username"] as? String

        return cell
    }

    func loadFollowedUsers() {
        let followQuery = PFQuery(className: "follower")

        followQuery.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId!)!)

        followQuery.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in

            if let objects = objects {
                for object in objects {
                    let followedUser = object["following"] as! String
                    let imageQuery   = PFQuery(className: "Image")

                    imageQuery.whereKey("userId", equalTo: followedUser)

                    imageQuery.findObjectsInBackgroundWithBlock({
                        (objects, error) -> Void in

                        if let objects = objects {
                            for object in objects {
                                let userid   = object["userId"] as! String
                                let username = self.userlist[userid]

                                let image = [
                                    "caption": object["caption"] as! String,
                                    "username": username!,
                                    "file": object["file"] as! PFFile
                                ]

                                self.images.append(image)
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }

    func loadUserNames() {
        let query = PFUser.query()

        query?.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in

            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        if user.objectId != PFUser.currentUser()?.objectId {
                            self.userlist[user.objectId!] = user.username!
                        }
                    }
                }
            }
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
