//
//  CoreDataHandler.swift
//  Remotly
//
//  Created by Marcin Czachurski on 25.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataHandler
{
    static func getManagedObjectContext() -> NSManagedObjectContext
    {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext!
        return managedContext
    }
    
    static func save(_ managedContext:NSManagedObjectContext) -> Bool
    {
        //var error: NSError?
      do {
        try managedContext.save()
      } catch let error {
        print("Could not save \(error), \(error.localizedDescription)")
        return false
      }
      
//        if !managedContext.save(error)
//        {
//            print("Could not save \(error), \(error?.userInfo)")
//            return false
//        }
//
        return true
    }
    
    static func createServerEntity(_ managedContext:NSManagedObjectContext) -> Server
    {
        let entity =  NSEntityDescription.entity(forEntityName: "Server", in: managedContext)
        let server = NSManagedObject(entity: entity!, insertInto:managedContext)
        return server as! Server
    }
    
    static func createTorrentEntity(_ server:Server, managedContext:NSManagedObjectContext) -> Torrent
    {
        let entity =  NSEntityDescription.entity(forEntityName: "Torrent", in: managedContext)
        let torrentEntity = NSManagedObject(entity: entity!, insertInto:managedContext)

        let torrent = torrentEntity as! Torrent
        torrent.server = server
        
        return torrent
    }
    
    static func getConfiguration(_ managedContext:NSManagedObjectContext) -> Configuration
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Configuration")
        
        //var error: NSError?
      
      
      //var fetchedObjects:[AnyObject]
      do {
        let fetchedObjects = try managedContext.fetch(fetchRequest)
        // success ...
        if(fetchedObjects.count == 1)
        {
          return fetchedObjects[0] as! Configuration
        }
        
        let entity =  NSEntityDescription.entity(forEntityName: "Configuration", in: managedContext)
        let configuration = NSManagedObject(entity: entity!, insertInto:managedContext)
        return configuration as! Configuration
        
      } catch let error as NSError {
        // failure
        print("Fetch failed: \(error.localizedDescription)")
      }
      
      let entity =  NSEntityDescription.entity(forEntityName: "Configuration", in: managedContext)
      let configuration = NSManagedObject(entity: entity!, insertInto:managedContext)
      return configuration as! Configuration
      
//        if(fetchedObjects?.count == 1)
//        {
//            return fetchedObjects![0] as! Configuration
//        }
//
//        let entity =  NSEntityDescription.entity(forEntityName: "Configuration", in: managedContext)
//        let configuration = NSManagedObject(entity: entity!, insertInto:managedContext)
//        return configuration as! Configuration
     
    }
    
    static func getServerFetchedResultsController(_ context:NSManagedObjectContext, delegate:NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let serversFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Server")
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        serversFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: serversFetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = delegate
        
        return frc
    }
    
    static func getTorrentFetchedResultsController(_ context:NSManagedObjectContext, server:Server, delegate:NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Torrent")
        let primarySortDescriptor = NSSortDescriptor(key: "addedDate", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let predicate = NSPredicate(format: "server == %@", server)
        fetchRequest.predicate = predicate
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = delegate
        
        return frc
    }
}
