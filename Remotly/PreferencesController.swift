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
    fileprivate var transmissionClient:TransmissionClient!
    fileprivate var isEditingFromTime = false
    fileprivate var isEditingToTime = false
    fileprivate var transmissionVersion = "-"
    fileprivate var rpcVersion = "-"
    fileprivate var scheduleSpeedDay = ScheduleSpeedDayEnum.off
    
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
        super.viewDidLoad()
           
        timeFromPickerOutlet.timeZone = TimeZone(secondsFromGMT: 0)
        timeToPickerOutlet.timeZone = TimeZone(secondsFromGMT: 0)
        
        getTransmissionPreferences();
        reloadRatesCellVisibility()
    }
    
    func dismissKeyboard()
    {
        globalDownloadRateOutlet.resignFirstResponder()
        globalUploadRateOutlet.resignFirstResponder()
        limitDownloadRateOutlet.resignFirstResponder()
        limitUploadRateOutlet.resignFirstResponder()
    }
    
    fileprivate func getTransmissionPreferences()
    {
      SwiftLoader.show(title: "Loading...", true)
        transmissionClient = TransmissionClient(address: server.address, userName: server.userName, password: server.password)
        transmissionClient.getTransmissionSessionInformation { (transmissionSession, error) -> Void in
            
            SwiftLoader.hide()
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
    
    fileprivate func reloadView(_ transmissionSession:TransmissionSession)
    {
        DispatchQueue.main.async {
            self.transmissionVersion = transmissionSession.version
            self.rpcVersion = "\(transmissionSession.rpcVersion)"
            self.globalDownloadRateSwitchOutlet.isOn = transmissionSession.speedLimitDownEnabled
            self.globalUploadRateSwitchOutlet.isOn = transmissionSession.speedLimitUpEnabled
            self.globalDownloadRateOutlet.text = "\(transmissionSession.speedLimitDown)"
            self.globalUploadRateOutlet.text = "\(transmissionSession.speedLimitUp)"
            self.limitDownloadRateOutlet.text = "\(transmissionSession.altSpeedDown)"
            self.limitUploadRateOutlet.text = "\(transmissionSession.altSpeedUp)"
            
            let minutesFrom = transmissionSession.altSpeedTimeBegin
            let dateFrom = Date(timeIntervalSinceReferenceDate: Double(minutesFrom * 60))
            self.timeFromPickerOutlet.date = dateFrom
            let dateFromValue = FormatHandler.getHoursAndMinutesFormat(dateFrom)
            self.timeFromOutlet.text = dateFromValue
            
            let minutesTo = transmissionSession.altSpeedTimeEnd
            let dateTo = Date(timeIntervalSinceReferenceDate: Double(minutesTo * 60))
            self.timeToPickerOutlet.date = dateTo
            let dateToValue = FormatHandler.getHoursAndMinutesFormat(dateTo)
            self.timeToOutlet.text = dateToValue
            
            self.reloadScheduleSpeedDay(transmissionSession.altSpeedTimeDay)
            self.reloadRatesCellVisibility()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func cancelAction(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: AnyObject)
    {
        var transmissionSession = TransmissionSession()
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        transmissionSession.altSpeedTimeDay = scheduleSpeedDay == .off ? ScheduleSpeedDayEnum.everyDay : scheduleSpeedDay
        transmissionSession.altSpeedTimeEnabled = scheduleSpeedDay != .off
        transmissionSession.speedLimitDownEnabled = globalDownloadRateSwitchOutlet.isOn
        transmissionSession.speedLimitUpEnabled = globalUploadRateSwitchOutlet.isOn
        
      if let altSpeedDown = Int(limitDownloadRateOutlet.text!)
        {
            transmissionSession.altSpeedDown = Int32(altSpeedDown)
        }
        
        if let altSpeedUp = Int(limitUploadRateOutlet.text!)
        {
            transmissionSession.altSpeedUp = Int32(altSpeedUp)
        }
        
        if let speedLimitDown = Int(globalDownloadRateOutlet.text!)
        {
            transmissionSession.speedLimitDown = Int32(speedLimitDown)
        }
        
        if let speedLimitUp = Int(globalUploadRateOutlet.text!)
        {
            transmissionSession.speedLimitUp = Int32(speedLimitUp)
        }
        
        var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: timeFromPickerOutlet.date)
        var altSpeedTimeBegin = components.hour! * 60 + components.minute!
        transmissionSession.altSpeedTimeBegin = Int32(altSpeedTimeBegin)
        
        components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: timeToPickerOutlet.date)
        var altSpeedTimeEnd = components.hour! * 60 + components.minute!
        transmissionSession.altSpeedTimeEnd = Int32(altSpeedTimeEnd)
        
        SwiftLoader.show(title: "Saving...", true)
        transmissionClient.setTransmissionSession(transmissionSession) { (error) -> Void in
            
            SwiftLoader.hide()
            if(error != nil)
            {
                DispatchQueue.main.async {
                    NotificationHandler.showError("Error", message: error!.localizedDescription)
                }
            }
            else
            {
                self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.async {
                    NotificationHandler.showSuccess("Success", message: "Session data was saved successfully")
                }
            }
        }

    }
    
    @IBAction func switchRateWasChanged(_ sender: AnyObject)
    {
        reloadRatesCellVisibility()
        tableView.reloadData()
    }

    @IBAction func timeFromChanged(_ sender: AnyObject)
    {
        var date = FormatHandler.getHoursAndMinutesFormat(timeFromPickerOutlet.date)
        timeFromOutlet.text = date
    }
    
    @IBAction func timeToChanged(_ sender: AnyObject)
    {
        var date = FormatHandler.getHoursAndMinutesFormat(timeToPickerOutlet.date)
        timeToOutlet.text = date
    }
    
    fileprivate func reloadRatesCellVisibility()
    {
        self.globalDownloadRateCellOutlet.isHidden = !self.globalDownloadRateSwitchOutlet.isOn
        self.globalUploadRataCellOutlet.isHidden = !self.globalUploadRateSwitchOutlet.isOn
        self.timeFromPickerCellOutlet.isHidden = !self.isEditingFromTime
        self.timeToPickerCellOutlet.isHidden = !self.isEditingToTime
        self.scheduleSpeedLimitFromCellOutlet.isHidden = self.scheduleSpeedDay == .off
        self.scheduleSpeedLimitToCellOutlet.isHidden = self.scheduleSpeedDay == .off
    }
    
    fileprivate func reloadScheduleSpeedDay(_ scheduleSpeedDay:ScheduleSpeedDayEnum)
    {
        self.scheduleSpeedDay = scheduleSpeedDay
        self.scheduleSpeedLimitValueOutlet.text = self.getSecheduleSpeedLimitValue(scheduleSpeedDay)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(indexPath.section == 0 && indexPath.row == 1 && !globalDownloadRateSwitchOutlet.isOn)
        {
            return 0.0
        }
        else if(indexPath.section == 0 && indexPath.row == 3 && !globalUploadRateSwitchOutlet.isOn)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
                timeFromPickerCellOutlet.isHidden = !isEditingFromTime
                
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    tableView.reloadRows(at: [IndexPath(row: 4, section: 1)], with: UITableViewRowAnimation.fade)
                    tableView.reloadData()
                })
            }
            else if(indexPath.row == 5)
            {
                isEditingToTime = !isEditingToTime
                timeToPickerCellOutlet.isHidden = !isEditingToTime
                
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    tableView.reloadRows(at: [IndexPath(row: 6, section: 1)], with: UITableViewRowAnimation.fade)
                    tableView.reloadData()
                })
            }
        }
    }
    
    fileprivate func getSecheduleSpeedLimitValue(_ scheduleSpeedDay:ScheduleSpeedDayEnum) -> String
    {
        switch(scheduleSpeedDay)
        {
            case .off:
                return "Off"
            case .everyDay:
                return "Every day"
            case .friday:
                return "Friday"
            case .monday:
                return "Monday"
            case .saturday:
                return "Saturday"
            case .sunday:
                return "Sunday"
            case .thursday:
                return "Thursday"
            case .tuesday:
                return "Tuesday"
            case .wednesday:
                return "Wednesday"
            case .weekdays:
                return "Weekdays"
            case .weekends:
                return "Weekends"
            default:
                return "Unknown"
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        if(section == 1)
        {
            return "Transmission version: \(transmissionVersion), RPC version: \(rpcVersion)"
        }
        
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "ScheduleSpeedLimitSegue")
        {
            var destinationController = segue.destination as? ScheduleSpeedDaysController
            if(destinationController != nil)
            {
                destinationController!.scheduleSpeedDay = self.scheduleSpeedDay
            }
        }
    }
    
    @IBAction func setScheduleDay(_ segue: UIStoryboardSegue)
    {
        let controller = segue.source as? ScheduleSpeedDaysController
        if(controller != nil)
        {
            reloadScheduleSpeedDay(controller!.scheduleSpeedDay)
            reloadRatesCellVisibility()
            tableView.reloadData()
        }
    }
}
