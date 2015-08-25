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
        var managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        return managedContext
    }
    
    static func save(managedContext:NSManagedObjectContext) -> Bool
    {
        var error: NSError?
        if !managedContext.save(&error)
        {
            println("Could not save \(error), \(error?.userInfo)")
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
    
    static func getConfiguration(managedContext:NSManagedObjectContext) -> Configuration
    {
        let fetchRequest = NSFetchRequest(entityName: "Configuration")
        
        var error: NSError?
        var fetchedObjects = managedContext.executeFetchRequest(fetchRequest, error: &error)
        
        if(fetchedObjects?.count == 1)
        {
            return fetchedObjects![0] as! Configuration
        }

        let entity =  NSEntityDescription.entityForName("Configuration", inManagedObjectContext: managedContext)
        let configuration = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        return configuration as! Configuration
    }
}