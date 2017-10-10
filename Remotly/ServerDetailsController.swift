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
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if(server != nil)
        {
            nameOutlet.text = server!.name
            addressOutlet.text = server!.address
            userNameOutlet.text = server!.userName
            passwordOutlet.text = server!.password
            
            var managedContext = CoreDataHandler.getManagedObjectContext()
            var configuration = CoreDataHandler.getConfiguration(managedContext)
            isDefaultOutlet.isOn = server!.objectID == configuration.defaultServer?.objectID
        }
        
        checkValidData(self)
    }
    
    @IBAction func checkValidData(_ sender: AnyObject)
    {
        if(isValidData())
        {
            saveButtonOutlet.isEnabled = true
        }
        else
        {
            saveButtonOutlet.isEnabled = false
        }
    }
    
    @IBAction func cancelAction(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: AnyObject)
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
        
        server!.name = nameOutlet.text!
        server!.address = addressOutlet.text!
        server!.userName = userNameOutlet.text!
        server!.password = passwordOutlet.text!
        
        var configuration = CoreDataHandler.getConfiguration(managedContext)
        if(isDefaultOutlet.isOn)
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
        
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func isValidData() -> Bool
    {
        var isValid = true
        if(nameOutlet.text?.isEmpty)!
        {
            isValid = false
        }
        
        if(addressOutlet.text?.isEmpty)!
        {
            isValid = false
        }
        
        return isValid
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
