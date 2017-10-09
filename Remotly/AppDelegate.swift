//
//  AppDelegate.swift
//  Remotly
//
//  Created by Marcin Czachurski on 28.07.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {

    var window: UIWindow?
    var fileUrl:URL?
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        fileUrl = url
        
        if(fileUrl == nil)
        {
            return false
        }
        
        if(fileUrl!.pathExtension == "torrent")
        {
            addTorrentViaFile()
        }
        else if(fileUrl!.scheme == "magnet")
        {
            addTorrentViaMagnetLink()
        }
        
        return true
    }
    
    fileprivate func getDefaultServer() -> Server?
    {
        var managedContext = CoreDataHandler.getManagedObjectContext()
        var configuration = CoreDataHandler.getConfiguration(managedContext)
        
        if(configuration.defaultServer == nil)
        {
            NotificationHandler.showError("Error", message: "You have to set default server.")
            return nil
        }
        
        return configuration.defaultServer
    }
    
    fileprivate func addTorrentViaFile()
    {
        let fileName = fileUrl!.lastPathComponent
        let alert = UIAlertView(title: "Torrent file", message: "Do you want to download torrent: '\(fileName)'?", delegate: self, cancelButtonTitle: "Cancel")
        alert.alertViewStyle = UIAlertViewStyle.default
        alert.tag = 1
        alert.addButton(withTitle: "Yes")
        alert.show()
    }
    
    fileprivate func addTorrentViaMagnetLink()
    {
        var fileName = MagnetLinkHander.getFileName(fileUrl!)
        var alert = UIAlertView(title: "Torrent file", message: "Do you want to download torrent: '\(fileName)'?", delegate: self, cancelButtonTitle: "Cancel")
        alert.alertViewStyle = UIAlertViewStyle.default
        alert.tag = 2
        alert.addButton(withTitle: "Yes")
        alert.show()
    }
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int)
    {
        if(alertView.tag == 1 && buttonIndex == 1)
        {
            if let defaultServer = getDefaultServer()
            {
                addTorrent(defaultServer, isExternal: false)
            }
        }
        else if(alertView.tag == 2 && buttonIndex == 1)
        {
            if let defaultServer = getDefaultServer()
            {
                addTorrent(defaultServer, isExternal: true)
            }
        }
    }
    
    fileprivate func addTorrent(_ server:Server, isExternal:Bool)
    {
        var transmissionClient = TransmissionClient(address: server.address, userName:server.userName, password:server.password)
        transmissionClient.addTorrent(fileUrl!, isExternal:isExternal, onCompletion: { (error) -> Void in
            if(error != nil)
            {
                NotificationHandler.showError("Error", message: error!.localizedDescription)
            }
            else
            {
                NotificationHandler.showSuccess("Success", message: "Torrent was added")
            }
        })
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        UISwitch.appearance().tintColor = ColorsHandler.getMainColor()
        UISwitch.appearance().onTintColor = ColorsHandler.getMainColor()
        changeSwiftLoaderApperance()
        
        return true
    }

    fileprivate func changeSwiftLoaderApperance()
    {
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        config.backgroundColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 0.9)
        
        SwiftLoader.setConfig(config)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "net.sltch.Remotly" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Remotly", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Remotly.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        /*if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil*/
      do {
        try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
      } catch var error as NSError {
        print(error.localizedDescription)
        
      
            coordinator = nil
          print("coordinator is nil")
          
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
      if (managedObjectContext?.hasChanges)!{
        do {
          try managedObjectContext?.save()
        } catch let error {
          
          NSLog("Unresolved error \(error)")
          abort()
//        if let moc = self.managedObjectContext {
//            var error: NSError? = nil
//            if moc.hasChanges && !moc.save(&error) {
//                // Replace this implementation with code to handle the error appropriately.
//                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                NSLog("Unresolved error \(error), \(error!.userInfo)")
//                abort()
            }
        }
    }

}

