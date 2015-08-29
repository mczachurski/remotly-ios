//
//  ServersListController.swift
//  
//
//  Created by Marcin Czachurski on 25.08.2015.
//
//

import UIKit
import CoreData

class ServersListController: UITableViewController, NSFetchedResultsControllerDelegate {

    var context: NSManagedObjectContext!
    var configuration:Configuration?
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let frc = CoreDataHandler.getServerFetchedResultsController(self.context, delegate: self)
        return frc
    }()
    
    override func viewDidLoad()
    {
        context = CoreDataHandler.getManagedObjectContext()
        configuration = CoreDataHandler.getConfiguration(context)
        
        super.viewDidLoad()
        
        var error: NSError? = nil
        if (fetchedResultsController.performFetch(&error) == false)
        {
            print("An error occurred: \(error?.localizedDescription)")
        }

        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow()
        {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        configuration = CoreDataHandler.getConfiguration(context)
        self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ServerCell", forIndexPath: indexPath) as! ServersCell
        let server = fetchedResultsController.objectAtIndexPath(indexPath) as! Server
        
        var isDefault = configuration?.defaultServer?.objectID == server.objectID
        cell.setServer(server, isDefault: isDefault)
        
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let server = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Server
            
            if(self.configuration?.defaultServer?.objectID == server.objectID)
            {
                self.configuration?.defaultServer = nil
            }
            
            self.context.deleteObject(server)
            CoreDataHandler.save(self.context)
            
        })
        
        return [deleteAction]
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "EditServerSegue")
        {
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let serverDetailsController = destinationViewController.viewControllers.first as! ServerDetailsController
            
            var server = getServerForSender(sender)
            serverDetailsController.server = server
        }
        else if(segue.identifier == "TorrentsListSegue")
        {
            let torrentsViewController = segue.destinationViewController as! TorrentsListController
            
            var server = getServerForSender(sender)
            torrentsViewController.server = server
        }
    }
    
    private func getServerForSender(sender: AnyObject?) -> Server
    {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        var server = fetchedResultsController.objectAtIndexPath(indexPath!) as! Server
        
        return server
    }
}
