//
//  UserListViewController.swift
//  Clonagram
//
//  Created by Julian Nicholls on 12/01/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UserListViewController: UITableViewController {

    var userlist = [Dictionary<String, String>]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let query = PFUser.query()

        query?.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in

            if let users = objects {
                self.userlist.removeAll(keepCapacity: true)

                for object in users {
                    if let user = object as? PFUser {
                        if user.objectId != PFUser.currentUser()?.objectId {
                            let query = PFQuery(className: "follower")

                            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                            query.whereKey("following", equalTo: user.objectId!)

                            query.findObjectsInBackgroundWithBlock({
                                (objects, error) -> Void in

                                var following = "0"

                                if let objects = objects {
                                    if objects.count > 0 {
                                        following = "1"
                                    }
                                }

                                self.userlist.append(["name": user.username!, "id": user.objectId!, "following": following])

                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            }

//            print(self.userlist)
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userlist.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel!.text = userlist[indexPath.row]["name"]

        if userlist[indexPath.row]["following"] == "1" {
            cell.accessoryType = .Checkmark
        }
        
        // Configure the cell...

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let following = userlist[indexPath.row]["following"] == "1"

        if following {
            userlist[indexPath.row]["following"] = "0"

            let query = PFQuery(className: "follower")

            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("following", equalTo: userlist[indexPath.row]["id"]!)

            query.findObjectsInBackgroundWithBlock({
                (objects, error) -> Void in

                if let objects = objects {
                    for obj in objects {
                        obj.deleteInBackground()
                    }
                }
            })

            cell?.accessoryType = .None
        }
        else {
            userlist[indexPath.row]["following"] = "1"

            let relation = PFObject(className: "follower")

            relation["following"] = userlist[indexPath.row]["id"]
            relation["follower"]  = PFUser.currentUser()?.objectId

            relation.saveInBackground()

            cell?.accessoryType = .Checkmark
        }
    }






    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
