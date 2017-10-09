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
    
  lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let frc = CoreDataHandler.getServerFetchedResultsController(self.context, delegate: self)
        return frc
    }()
    
    override func viewDidLoad()
    {
        context = CoreDataHandler.getManagedObjectContext()
        configuration = CoreDataHandler.getConfiguration(context)
        
        super.viewDidLoad()
        
       // var error: NSError? = nil
      do{
        try fetchedResultsController.performFetch()
      }
      catch{
        print("An error occurred: \(error.localizedDescription)")
        }

        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow
        {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        configuration = CoreDataHandler.getConfiguration(context)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        if let sections = fetchedResultsController.sections
        {
            return sections.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = fetchedResultsController.sections
        {
            let currentSection = sections[section] as! NSFetchedResultsSectionInfo
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell", for: indexPath) as! ServersCell
        let server = fetchedResultsController.object(at: indexPath) as! Server
        
        var isDefault = configuration?.defaultServer?.objectID == server.objectID
        cell.setServer(server, isDefault: isDefault)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    //override func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [AnyObject]?
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            let server = self.fetchedResultsController.object(at: indexPath) as! Server
            
            if(self.configuration?.defaultServer?.objectID == server.objectID)
            {
                self.configuration?.defaultServer = nil
            }
            
            self.context.delete(server)
            CoreDataHandler.save(self.context)
            
        })
        
        return [deleteAction]
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "EditServerSegue")
        {
            let destinationViewController = segue.destination as! UINavigationController
            let serverDetailsController = destinationViewController.viewControllers.first as! ServerDetailsController
            
            let server = getServerForSender(sender as AnyObject)
            serverDetailsController.server = server
        }
        else if(segue.identifier == "TorrentsListSegue")
        {
            let torrentsViewController = segue.destination as! TorrentsListController
            
            let server = getServerForSender(sender as AnyObject)
            torrentsViewController.server = server
        }
    }
    
    fileprivate func getServerForSender(_ sender: AnyObject?) -> Server
    {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        var server = fetchedResultsController.object(at: indexPath!) as! Server
        
        return server
    }
}
