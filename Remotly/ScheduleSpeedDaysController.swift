//
//  ScheduleSpeedDaysController.swift
//  Remotly
//
//  Created by Marcin Czachurski on 29.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit

class ScheduleSpeedDaysController : UITableViewController
{
    @IBOutlet weak var offCellOutlet: UITableViewCell!
    @IBOutlet weak var everydayCellOutlet: UITableViewCell!
    @IBOutlet weak var weekdaysCellOutlet: UITableViewCell!
    @IBOutlet weak var weekendsCellOutlet: UITableViewCell!
    @IBOutlet weak var mondayCellOutlet: UITableViewCell!
    @IBOutlet weak var tuesdayCellOutlet: UITableViewCell!
    @IBOutlet weak var wednesdayCellOutlet: UITableViewCell!
    @IBOutlet weak var thursdayCellOutlet: UITableViewCell!
    @IBOutlet weak var fridayCellOutlet: UITableViewCell!
    @IBOutlet weak var saturdayCellOutlet: UITableViewCell!
    @IBOutlet weak var sundayCellOutlet: UITableViewCell!
    
    var scheduleSpeedDay = ScheduleSpeedDayEnum.Off
    
    override func viewDidLoad()
    {
        deselectAll()
        let indexPath = getIndexPathForEnum(scheduleSpeedDay)
        selectRow(indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        deselectAll()
        scheduleSpeedDay = selectRow(indexPath)
    }
    
    private func deselectAll()
    {
        offCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        everydayCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        weekdaysCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        weekendsCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        mondayCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        tuesdayCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        wednesdayCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        thursdayCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        fridayCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        saturdayCellOutlet.accessoryType = UITableViewCellAccessoryType.None
        sundayCellOutlet.accessoryType = UITableViewCellAccessoryType.None
    }
    
    private func selectRow(indexPath:NSIndexPath) -> ScheduleSpeedDayEnum
    {
        switch(indexPath.section, indexPath.row)
        {
        case (0, 1):
            everydayCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.EveryDay
        case (0, 2):
            weekdaysCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Weekdays
        case (0, 3):
            weekendsCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Weekends
        case (1, 0):
            mondayCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Monday
        case (1, 1):
            tuesdayCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Tuesday
        case (1, 2):
            wednesdayCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Wednesday
        case (1, 3):
            thursdayCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Thursday
        case (1, 4):
            fridayCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Friday
        case (1, 5):
            saturdayCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Saturday
        case (1, 6):
            sundayCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Sunday
        default:
            offCellOutlet.accessoryType = UITableViewCellAccessoryType.Checkmark
            return ScheduleSpeedDayEnum.Off
        }
    }
    
    private func getIndexPathForEnum(schedule:ScheduleSpeedDayEnum) -> NSIndexPath
    {
        switch(schedule)
        {
            case .EveryDay:
                return NSIndexPath(forRow: 1, inSection: 0)
            case .Weekdays:
                return NSIndexPath(forRow: 2, inSection: 0)
            case .Weekends:
                return NSIndexPath(forRow: 3, inSection: 0)
            case .Monday:
                return NSIndexPath(forRow: 0, inSection: 1)
            case .Tuesday:
                return NSIndexPath(forRow: 1, inSection: 1)
            case .Wednesday:
                return NSIndexPath(forRow: 2, inSection: 1)
            case .Thursday:
                return NSIndexPath(forRow: 3, inSection: 1)
            case .Friday:
                return NSIndexPath(forRow: 4, inSection: 1)
            case .Saturday:
                return NSIndexPath(forRow: 5, inSection: 1)
            case .Sunday:
                return NSIndexPath(forRow: 6, inSection: 1)
            default:
                return NSIndexPath(forRow: 0, inSection: 0)
        }
    }
}
