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
    }
    
    @IBAction func cancelAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject)
    {
        if(!validateData())
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
            var alert = UIAlertView(title: "Error", message: "There is a problem during saving data", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func validateData() -> Bool
    {
        var isValid = true
        if(nameOutlet.text.isEmpty)
        {
            nameOutlet.backgroundColor = ColorsHandler.getValidationErrorColor()
            isValid = false
        }
        else
        {
            nameOutlet.backgroundColor = UIColor.whiteColor()
        }
        
        if(addressOutlet.text.isEmpty)
        {
            addressOutlet.backgroundColor = ColorsHandler.getValidationErrorColor()
            isValid = false
        }
        else
        {
            addressOutlet.backgroundColor = UIColor.whiteColor()
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
