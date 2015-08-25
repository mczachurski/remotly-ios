//
//  TorrentsListController.swift
//  Remotly
//
//  Created by Marcin Czachurski on 30.07.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit

class TorrentsListController: UITableViewController, UIAlertViewDelegate {

    var transmissionClient:TransmissionClient!
    
    @IBAction func addNewTorrentAction(sender: AnyObject)
    {        
        var alert = UIAlertView(title: "Torrent url", message: "Please enter url to torrent file", delegate: self, cancelButtonTitle: "Cancel")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.tag = 1
        alert.addButtonWithTitle("Add")
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int)
    {
        if(alertView.tag == 1)
        {
            if(buttonIndex == 1)
            {
                var textfield = alertView.textFieldAtIndex(0)
                var fileString = textfield?.text
                var fileUrl = NSURL(string: fileString!)

                transmissionClient.addTorrent(fileUrl!, isExternal:true, onCompletion: { (error) -> Void in
                    if(error != nil)
                    {
                        // Print error.
                    }
                    else
                    {
                        AppDelegate.shouldRefreshList = true
                    }
                })
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = ColorsHandler.getMainColor()
        self.refreshControl!.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: "reloadTorrents", forControlEvents: UIControlEvents.ValueChanged)
        
        transmissionClient.loadTorrents(torrentsLoadedCallback)
    }

    override func viewWillAppear(animated: Bool)
    {
        if(AppDelegate.shouldRefreshList)
        {
            AppDelegate.shouldRefreshList = false
            reloadTorrents()
        }
    }
    
    func torrentsLoadedCallback(error:NSError?)
    {
        if(error == nil)
        {
            reloadData()
        }
    }
    
    func reloadTorrents()
    {
        transmissionClient.loadTorrents(torrentsLoadedCallback)
    }
    
    func reloadData()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        
        if(self.refreshControl != nil)
        {
            var formatter = NSDateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            let dateString = formatter.stringFromDate(NSDate())
            var title = "Last update: \(dateString)"
            var attrsDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            var attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
            self.refreshControl!.attributedTitle = attributedTitle
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if(transmissionClient.torrentsInformation.count > 0)
        {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }
        else
        {
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            
            messageLabel.text = "No data is currently available. Please pull down to refresh."
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return transmissionClient.torrentsInformation.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TorrentCell", forIndexPath: indexPath) as! TorrentsCell

        let torrentInformation = transmissionClient.torrentsInformation[indexPath.row]
        cell.setTorrent(torrentInformation)

        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        let torrentInformation = transmissionClient.torrentsInformation[indexPath.row]

        var runAction:UITableViewRowAction
        if(torrentInformation.isPaused)
        {            
            runAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Reasume", handler: { (action, indexPath) -> Void in
                self.transmissionClient.reasumeTorrent(torrentInformation.id, onCompletion: { (error) -> Void in
                    self.reloadTorrents()
                })
            })
            runAction.backgroundColor = ColorsHandler.getGrayColor()
        }
        else
        {
            runAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Pause" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                self.transmissionClient.pauseTorrent(torrentInformation.id, onCompletion: { (error) -> Void in
                    self.reloadTorrents()
                })
            })
            runAction.backgroundColor = ColorsHandler.getGrayColor()
        }
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.transmissionClient.removeTorrent(torrentInformation.id, onCompletion: nil)
        })
        
        return [deleteAction, runAction]
    }
}
