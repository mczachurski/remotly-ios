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
    private var transmissionClient:TransmissionClient!
    private var isEditingFromTime = false
    private var isEditingToTime = false
    private var transmissionVersion = "-"
    private var rpcVersion = "-"
    private var scheduleSpeedDay = ScheduleSpeedDayEnum.Off
    
    @IBOutlet weak var globalDownloadRateCellOutlet: UITableViewCell!
    @IBOutlet weak var globalUploadRataCellOutlet: UITableViewCell!
    @IBOutlet weak var globalDownloadRateSwitchOutlet: UISwitch!
    @IBOutlet weak var globalUploadRateSwitchOutlet: UISwitch!
    @IBOutlet weak var globalDownloadRateOutlet: UITextField!
    @IBOutlet weak var globalUploadRateOutlet: UITextField!
    @IBOutlet weak var limitDownloadRateOutlet: UITextField!
    @IBOutlet weak var limitUploadRateOutlet: UITextField!
    @IBOutlet weak var timeFromPickerCellOutlet: UITableViewCell!
    @IBOutlet weak var timeToPickerCellOutlet: UITableViewCell!
    @IBOutlet weak var timeFromOutlet: UILabel!
    @IBOutlet weak var timeToOutlet: UILabel!
    @IBOutlet weak var timeFromPickerOutlet: UIDatePicker!
    @IBOutlet weak var timeToPickerOutlet: UIDatePicker!
    @IBOutlet weak var scheduleSpeedLimitValueOutlet: UILabel!
    @IBOutlet weak var scheduleSpeedLimitFromCellOutlet: UITableViewCell!
    @IBOutlet weak var scheduleSpeedLimitToCellOutlet: UITableViewCell!
    
    override func viewDidLoad()
    {
        timeFromPickerOutlet.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        timeToPickerOutlet.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        getTransmissionPreferences();
        reloadRatesCellVisibility()
    }
    
    private func getTransmissionPreferences()
    {
        transmissionClient = TransmissionClient(address: server.address, userName: server.userName, password: server.password)
        transmissionClient.getTransmissionSessionInformation { (transmissionSession, error) -> Void in
            if(error != nil)
            {
                NotificationHandler.showError("Error", message: error!.localizedDescription)
            }
            else
            {
                self.reloadView(transmissionSession)
            }
        }
    }
    
    private func reloadView(transmissionSession:TransmissionSession)
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.transmissionVersion = transmissionSession.version
            self.rpcVersion = "\(transmissionSession.rpcVersion)"
            self.globalDownloadRateSwitchOutlet.on = transmissionSession.speedLimitDownEnabled
            self.globalUploadRateSwitchOutlet.on = transmissionSession.speedLimitUpEnabled
            self.globalDownloadRateOutlet.text = "\(transmissionSession.speedLimitDown)"
            self.globalUploadRateOutlet.text = "\(transmissionSession.speedLimitUp)"
            self.limitDownloadRateOutlet.text = "\(transmissionSession.altSpeedDown)"
            self.limitUploadRateOutlet.text = "\(transmissionSession.altSpeedUp)"
            
            let minutesFrom = transmissionSession.altSpeedTimeBegin
            let dateFrom = NSDate(timeIntervalSinceReferenceDate: Double(minutesFrom * 60))
            self.timeFromPickerOutlet.date = dateFrom
            let dateFromValue = FormatHandler.getHoursAndMinutesFormat(dateFrom)
            self.timeFromOutlet.text = dateFromValue
            
            let minutesTo = transmissionSession.altSpeedTimeEnd
            let dateTo = NSDate(timeIntervalSinceReferenceDate: Double(minutesTo * 60))
            self.timeToPickerOutlet.date = dateTo
            let dateToValue = FormatHandler.getHoursAndMinutesFormat(dateTo)
            self.timeToOutlet.text = dateToValue
            
            self.reloadScheduleSpeedDay(transmissionSession.altSpeedTimeDay)
            self.reloadRatesCellVisibility()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject)
    {
        var transmissionSession = TransmissionSession()
        var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        transmissionSession.altSpeedTimeDay = scheduleSpeedDay == .Off ? ScheduleSpeedDayEnum.EveryDay : scheduleSpeedDay
        transmissionSession.altSpeedTimeEnabled = scheduleSpeedDay != .Off
        transmissionSession.speedLimitDownEnabled = globalDownloadRateSwitchOutlet.on
        transmissionSession.speedLimitUpEnabled = globalUploadRateSwitchOutlet.on
        
        if let altSpeedDown = limitDownloadRateOutlet.text.toInt()
        {
            transmissionSession.altSpeedDown = Int32(altSpeedDown)
        }
        
        if let altSpeedUp = limitUploadRateOutlet.text.toInt()
        {
            transmissionSession.altSpeedUp = Int32(altSpeedUp)
        }
        
        if let speedLimitDown = globalDownloadRateOutlet.text.toInt()
        {
            transmissionSession.speedLimitDown = Int32(speedLimitDown)
        }
        
        if let speedLimitUp = globalUploadRateOutlet.text.toInt()
        {
            transmissionSession.speedLimitUp = Int32(speedLimitUp)
        }
        
        var components = calendar.componentsInTimeZone(NSTimeZone(forSecondsFromGMT: 0), fromDate: timeFromPickerOutlet.date)
        var altSpeedTimeBegin = components.hour * 60 + components.minute
        transmissionSession.altSpeedTimeBegin = Int32(altSpeedTimeBegin)
        
        components = calendar.componentsInTimeZone(NSTimeZone(forSecondsFromGMT: 0), fromDate: timeToPickerOutlet.date)
        var altSpeedTimeEnd = components.hour * 60 + components.minute
        transmissionSession.altSpeedTimeEnd = Int32(altSpeedTimeEnd)
        
        transmissionClient.setTransmissionSession(transmissionSession) { (error) -> Void in
            if(error != nil)
            {
                dispatch_async(dispatch_get_main_queue()) {
                    NotificationHandler.showError("Error", message: error!.localizedDescription)
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue()) {
                    NotificationHandler.showSuccess("Success", message: "Session data was saved successfully")
                }
            }
        }

    }
    
    @IBAction func switchRateWasChanged(sender: AnyObject)
    {
        reloadRatesCellVisibility()
        tableView.reloadData()
    }

    @IBAction func timeFromChanged(sender: AnyObject)
    {
        var date = FormatHandler.getHoursAndMinutesFormat(timeFromPickerOutlet.date)
        timeFromOutlet.text = date
    }
    
    @IBAction func timeToChanged(sender: AnyObject)
    {
        var date = FormatHandler.getHoursAndMinutesFormat(timeToPickerOutlet.date)
        timeToOutlet.text = date
    }
    
    private func reloadRatesCellVisibility()
    {
        self.globalDownloadRateCellOutlet.hidden = !self.globalDownloadRateSwitchOutlet.on
        self.globalUploadRataCellOutlet.hidden = !self.globalUploadRateSwitchOutlet.on
        self.timeFromPickerCellOutlet.hidden = !self.isEditingFromTime
        self.timeToPickerCellOutlet.hidden = !self.isEditingToTime
        self.scheduleSpeedLimitFromCellOutlet.hidden = self.scheduleSpeedDay == .Off
        self.scheduleSpeedLimitToCellOutlet.hidden = self.scheduleSpeedDay == .Off
    }
    
    private func reloadScheduleSpeedDay(scheduleSpeedDay:ScheduleSpeedDayEnum)
    {
        self.scheduleSpeedDay = scheduleSpeedDay
        self.scheduleSpeedLimitValueOutlet.text = self.getSecheduleSpeedLimitValue(scheduleSpeedDay)
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
        else if(indexPath.section == 1 && indexPath.row == 3 && scheduleSpeedLimitValueOutlet.text == "Off")
        {
            return 0.0
        }
        else if(indexPath.section == 1 && indexPath.row == 4)
        {
            return isEditingFromTime ? 220.0 : 0.0
        }
        else if(indexPath.section == 1 && indexPath.row == 5 && scheduleSpeedLimitValueOutlet.text == "Off")
        {
            return 0.0
        }
        else if(indexPath.section == 1 && indexPath.row == 6)
        {
            return isEditingToTime ? 220.0 : 0.0
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
            else if(indexPath.row == 3)
            {
                isEditingFromTime = !isEditingFromTime
                timeFromPickerCellOutlet.hidden = !isEditingFromTime
                
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 4, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.reloadData()
                })
            }
            else if(indexPath.row == 5)
            {
                isEditingToTime = !isEditingToTime
                timeToPickerCellOutlet.hidden = !isEditingToTime
                
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 6, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.reloadData()
                })
            }
        }
    }
    
    private func getSecheduleSpeedLimitValue(scheduleSpeedDay:ScheduleSpeedDayEnum) -> String
    {
        switch(scheduleSpeedDay)
        {
            case .Off:
                return "Off"
            case .EveryDay:
                return "Every day"
            case .Friday:
                return "Friday"
            case .Monday:
                return "Monday"
            case .Saturday:
                return "Saturday"
            case .Sunday:
                return "Sunday"
            case .Thursday:
                return "Thursday"
            case .Tuesday:
                return "Tuesday"
            case .Wednesday:
                return "Wednesday"
            case .Weekdays:
                return "Weekdays"
            case .Weekends:
                return "Weekends"
            default:
                return "Unknown"
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        if(section == 1)
        {
            return "Transmission version: \(transmissionVersion), RPC version: \(rpcVersion)"
        }
        
        return nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "ScheduleSpeedLimitSegue")
        {
            var destinationController = segue.destinationViewController as? ScheduleSpeedDaysController
            if(destinationController != nil)
            {
                destinationController!.scheduleSpeedDay = self.scheduleSpeedDay
            }
        }
    }
    
    @IBAction func setScheduleDay(segue: UIStoryboardSegue)
    {
        var controller = segue.sourceViewController as? ScheduleSpeedDaysController
        if(controller != nil)
        {
            reloadScheduleSpeedDay(controller!.scheduleSpeedDay)
            reloadRatesCellVisibility()
            tableView.reloadData()
        }
    }
}