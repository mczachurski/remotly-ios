//
//  TorrentsListController.swift
//  Remotly
//
//  Created by Marcin Czachurski on 30.07.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit
import CoreData

class TorrentsListController: UITableViewController, UIAlertViewDelegate, NSFetchedResultsControllerDelegate
{
    var server:Server!
    private var transmissionClient:TransmissionClient!
    private var context: NSManagedObjectContext!
    private var reloadTimer:NSTimer?
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Torrent")
        let primarySortDescriptor = NSSortDescriptor(key: "addedDate", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let predicate = NSPredicate(format: "server == %@", self.server)
        fetchRequest.predicate = predicate
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
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
                        var alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                })
            }
        }
    }
    
    override func viewDidLoad()
    {
        context = CoreDataHandler.getManagedObjectContext()
        transmissionClient = TransmissionClient(address: server.address, userName: server.userName, password: server.password)
        
        super.viewDidLoad()
        
        var error: NSError? = nil
        if (fetchedResultsController.performFetch(&error) == false)
        {
            print("An error occurred: \(error?.localizedDescription)")
        }

        self.clearsSelectionOnViewWillAppear = true
    }
        
    override func viewDidAppear(animated: Bool)
    {
        reloadTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(4.0), target: self, selector: Selector("reloadTimer:"), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
    }
    
    private func invalidateReloadTimer()
    {
        reloadTimer?.invalidate()
        reloadTimer = nil
    }
    
    func reloadTimer(timer:NSTimer)
    {
        self.reloadTorrents()
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.beginUpdates()
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.endUpdates()
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        dispatch_async(dispatch_get_main_queue()) {
            switch(type) {
                case NSFetchedResultsChangeType.Insert:
                    self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
                    break;
                case NSFetchedResultsChangeType.Delete:
                    self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
                    break;
                default:
                    break
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        dispatch_async(dispatch_get_main_queue()) {
            var tableView = self.tableView
            
            switch(type)
            {
                case NSFetchedResultsChangeType.Insert:
                    tableView.insertRowsAtIndexPaths(NSArray(object: newIndexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
                    break;
                
                case NSFetchedResultsChangeType.Delete:
                    tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
                    break;
                
                case NSFetchedResultsChangeType.Update:

                    var cell = tableView.cellForRowAtIndexPath(indexPath!) as! TorrentsCell
                    let torrent = self.fetchedResultsController.objectAtIndexPath(indexPath!) as! Torrent
                    cell.setTorrent(torrent)
                
                    break;
                
                case NSFetchedResultsChangeType.Move:
                    tableView.deleteRowsAtIndexPaths(NSArray(object: newIndexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.insertRowsAtIndexPaths(NSArray(object: indexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
                    break;
            }
        }
    }
    
    func reloadTorrents()
    {
        transmissionClient.getTorrents(torrentsLoadedCallback)
    }
    
    func torrentsLoadedCallback(torrentInformations:[TorrentInformation]!, error:NSError?)
    {
        if(error != nil)
        {
            dispatch_async(dispatch_get_main_queue()) {
                self.invalidateReloadTimer();
                var alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
            return
        }

        synchronizeWithCoreData(torrentInformations)
    }
    
    private func synchronizeWithCoreData(torrentInformations:[TorrentInformation]!)
    {
        var torrentsFromCoreData = fetchedResultsController.fetchedObjects as! [Torrent]
        
        for torrentFromServer in torrentInformations
        {
            var wasSynchronized = false
            for torrentFromCoreData in torrentsFromCoreData
            {
                if(torrentFromServer.hashString == torrentFromCoreData.hashString)
                {
                    torrentFromCoreData.synchronizeData(torrentFromServer)
                    wasSynchronized = true
                    break
                }
            }
            
            if(!wasSynchronized)
            {
                var newTorrent = CoreDataHandler.createTorrentEntity(server, managedContext: context)
                newTorrent.synchronizeData(torrentFromServer)
            }
        }
        
        for torrentFromCoreData in torrentsFromCoreData
        {
            var isExist = false
            for torrentFromServer in torrentInformations
            {
                if(torrentFromServer.hashString == torrentFromCoreData.hashString)
                {
                    isExist = true
                    break
                }
            }
            
            if(!isExist)
            {
                context.deleteObject(torrentFromCoreData)
            }
        }
        
        CoreDataHandler.save(context)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if let sections = fetchedResultsController.sections
        {
            return sections.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = fetchedResultsController.sections
        {
            let currentSection = sections[section] as! NSFetchedResultsSectionInfo
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TorrentCell", forIndexPath: indexPath) as! TorrentsCell
        let torrent = fetchedResultsController.objectAtIndexPath(indexPath) as! Torrent
        
        cell.setTorrent(torrent)
        
        return cell
    }
        
    // MARK: - Navigation
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        let torrentInformation = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Torrent

        var runAction:UITableViewRowAction
        if(torrentInformation.isPaused)
        {            
            runAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Reasume", handler: { (action, indexPath) -> Void in
                self.transmissionClient.reasumeTorrent(torrentInformation.id, onCompletion: { (error) -> Void in
                    
                    if(error != nil)
                    {
                        var alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    
                    self.reloadTorrents()
                })
                
                tableView.setEditing(false, animated: true)
            })
            runAction.backgroundColor = ColorsHandler.getGrayColor()
        }
        else
        {
            runAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Pause" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                self.transmissionClient.pauseTorrent(torrentInformation.id, onCompletion: { (error) -> Void in
                    
                    if(error != nil)
                    {
                        var alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    
                    self.reloadTorrents()
                })
                
                tableView.setEditing(false, animated: true)
            })
            runAction.backgroundColor = ColorsHandler.getGrayColor()
        }
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.transmissionClient.removeTorrent(torrentInformation.id, onCompletion: { (error) -> Void in
                
                if(error != nil)
                {
                    var alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                
                self.reloadTorrents()
            })
            
            tableView.setEditing(false, animated: true)
        })
        
        return [deleteAction, runAction]
    }
}
