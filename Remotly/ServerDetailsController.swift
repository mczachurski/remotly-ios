//
//  NewServerController.swift
//  Remotly
//
//  Created by Marcin Czachurski on 30.07.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit
import CoreData

class ServerDetailsController: UITableViewController
{
    var server:Server?
    
    @IBOutlet weak var nameOutlet: UITextField!
    @IBOutlet weak var addressOutlet: UITextField!
    @IBOutlet weak var userNameOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var isDefaultOutlet: UISwitch!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool)
    {
        if(server != nil)
        {
            nameOutlet.text = server!.name
            addressOutlet.text = server!.address
            userNameOutlet.text = server!.userName
            passwordOutlet.text = server!.password
            
            var managedContext = CoreDataHandler.getManagedObjectContext()
            var configuration = CoreDataHandler.getConfiguration(managedContext)
            isDefaultOutlet.on = server!.objectID == configuration.defaultServer?.objectID
        }
        
        checkValidData(self)
    }
    
    @IBAction func checkValidData(sender: AnyObject)
    {
        if(isValidData())
        {
            saveButtonOutlet.enabled = true
        }
        else
        {
            saveButtonOutlet.enabled = false
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject)
    {
        if(!isValidData())
        {
            return
        }
        
        var managedContext = CoreDataHandler.getManagedObjectContext()
        if(server == nil)
        {
            server = CoreDataHandler.createServerEntity(managedContext)
        }
        
        server!.name = nameOutlet.text
        server!.address = addressOutlet.text
        server!.userName = userNameOutlet.text
        server!.password = passwordOutlet.text
        
        var configuration = CoreDataHandler.getConfiguration(managedContext)
        if(isDefaultOutlet.on)
        {
            configuration.defaultServer = server!
        }
        else if(configuration.defaultServer?.objectID == server!.objectID)
        {
            configuration.defaultServer = nil
        }
        
        if(!CoreDataHandler.save(managedContext))
        {
            NotificationHandler.showError("Error", message: "There is a problem during saving data")
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func isValidData() -> Bool
    {
        var isValid = true
        if(nameOutlet.text.isEmpty)
        {
            isValid = false
        }
        
        if(addressOutlet.text.isEmpty)
        {
            isValid = false
        }
        
        return isValid
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if(indexPath.section == 0)
        {
            switch(indexPath.row)
            {
                case 0:
                    nameOutlet.becomeFirstResponder()
                case 1:
                    addressOutlet.becomeFirstResponder()
                default:
                    break;
            }
        }
        else if(indexPath.section == 1)
        {
            switch(indexPath.row)
            {
            case 0:
                userNameOutlet.becomeFirstResponder()
            case 1:
                passwordOutlet.becomeFirstResponder()
            default:
                break;
            }
        }
    }
}
