//
//  PreferencesController.swift
//  Remotly
//
//  Created by Marcin Czachurski on 28.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit

class PreferencesController : UITableViewController
{
    var server:Server!
    var transmissionClient:TransmissionClient!
    
    @IBOutlet weak var globalDownloadRateCellOutlet: UITableViewCell!
    @IBOutlet weak var globalUploadRataCellOutlet: UITableViewCell!
    @IBOutlet weak var globalDownloadRateSwitchOutlet: UISwitch!
    @IBOutlet weak var globalUploadRateSwitchOutlet: UISwitch!
    @IBOutlet weak var globalDownloadRateOutlet: UITextField!
    @IBOutlet weak var globalUploadRateOutlet: UITextField!
    @IBOutlet weak var limitDownloadRateOutlet: UITextField!
    @IBOutlet weak var limitUploadRateOutlet: UITextField!
    @IBOutlet weak var scheduleSpeedLimitSwitchOutlet: UISwitch!
    
    override func viewDidLoad()
    {
        transmissionClient = TransmissionClient(address: server.address, userName: server.userName, password: server.password)
        getTransmissionPreferences();
    }
    
    private func getTransmissionPreferences()
    {
        transmissionClient.getTransmissionSessionInformation { (transmissionSession, error) -> Void in
            if(error != nil)
            {
                NotificationHandler.showError("Error", message: error!.localizedDescription)
            }
            else
            {
                self.globalDownloadRateSwitchOutlet.on = transmissionSession.speedLimitDownEnabled
                self.globalUploadRateSwitchOutlet.on = transmissionSession.speedLimitUpEnabled
                self.globalDownloadRateOutlet.text = "\(transmissionSession.speedLimitDown)"
                self.globalUploadRateOutlet.text = "\(transmissionSession.speedLimitUp)"
                self.limitDownloadRateOutlet.text = "\(transmissionSession.altSpeedDown)"
                self.limitUploadRateOutlet.text = "\(transmissionSession.altSpeedUp)"
                
                self.reloadRatesCellVisibility()
            }
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func switchRateWasChanged(sender: AnyObject)
    {
        reloadRatesCellVisibility()
        tableView.reloadData()
    }

    private func reloadRatesCellVisibility()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.globalDownloadRateCellOutlet.hidden = !self.globalDownloadRateSwitchOutlet.on
            self.globalUploadRataCellOutlet.hidden = !self.globalUploadRateSwitchOutlet.on
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if(indexPath.section == 0 && indexPath.row == 1 && !globalDownloadRateSwitchOutlet.on)
        {
            return 0.0
        }
        else if(indexPath.section == 0 && indexPath.row == 3 && !globalUploadRateSwitchOutlet.on)
        {
            return 0.0
        }
        
        return 44.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if(indexPath.section == 0)
        {
            if(indexPath.row == 1)
            {
                globalDownloadRateOutlet.becomeFirstResponder()
            }
            else if(indexPath.row == 3)
            {
                globalUploadRateOutlet.becomeFirstResponder()
            }
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
                limitDownloadRateOutlet.becomeFirstResponder()
            }
            else if(indexPath.row == 1)
            {
                limitUploadRateOutlet.becomeFirstResponder()
            }
        }
    }
}