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
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        return managedContext
    }
    
    static func save(managedContext:NSManagedObjectContext) -> Bool
    {
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
            return false
        }
        
        return true
    }
    
    static func createServerEntity(managedContext:NSManagedObjectContext) -> Server
    {
        let entity =  NSEntityDescription.entityForName("Server", inManagedObjectContext: managedContext)
        let server = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        return server as! Server
    }
    
    static func createTorrentEntity(server:Server, managedContext:NSManagedObjectContext) -> Torrent
    {
        let entity =  NSEntityDescription.entityForName("Torrent", inManagedObjectContext: managedContext)
        let torrentEntity = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)

        let torrent = torrentEntity as! Torrent
        torrent.server = server
        
        return torrent
    }
    
    static func getConfiguration(managedContext:NSManagedObjectContext) -> Configuration
    {
        let fetchRequest = NSFetchRequest(entityName: "Configuration")
        
        var fetchedObjects: [AnyObject]?
        do {
            fetchedObjects = try managedContext.executeFetchRequest(fetchRequest)
        } catch {
            fetchedObjects = nil
        }
        
        if(fetchedObjects?.count == 1)
        {
            return fetchedObjects![0] as! Configuration
        }

        let entity =  NSEntityDescription.entityForName("Configuration", inManagedObjectContext: managedContext)
        let configuration = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        return configuration as! Configuration
    }
    
    static func getServerFetchedResultsController(context:NSManagedObjectContext, delegate:NSFetchedResultsControllerDelegate) -> NSFetchedResultsController
    {
        let serversFetchRequest = NSFetchRequest(entityName: "Server")
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
    
    static func getTorrentFetchedResultsController(context:NSManagedObjectContext, server:Server, delegate:NSFetchedResultsControllerDelegate) -> NSFetchedResultsController
    {
        let fetchRequest = NSFetchRequest(entityName: "Torrent")
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