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
    
    var scheduleSpeedDay = ScheduleSpeedDayEnum.off
    
    override func viewDidLoad()
    {
        deselectAll()
        let indexPath = getIndexPathForEnum(scheduleSpeedDay)
        selectRow(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        deselectAll()
        scheduleSpeedDay = selectRow(indexPath)
    }
    
    fileprivate func deselectAll()
    {
        offCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        everydayCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        weekdaysCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        weekendsCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        mondayCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        tuesdayCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        wednesdayCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        thursdayCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        fridayCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        saturdayCellOutlet.accessoryType = UITableViewCellAccessoryType.none
        sundayCellOutlet.accessoryType = UITableViewCellAccessoryType.none
    }
    
    fileprivate func selectRow(_ indexPath:IndexPath) -> ScheduleSpeedDayEnum
    {
        switch(indexPath.section, indexPath.row)
        {
        case (0, 0):
            offCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.off
        case (0, 1):
            everydayCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.everyDay
        case (0, 2):
            weekdaysCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.weekdays
        case (0, 3):
            weekendsCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.weekends
        case (1, 0):
            mondayCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.monday
        case (1, 1):
            tuesdayCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.tuesday
        case (1, 2):
            wednesdayCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.wednesday
        case (1, 3):
            thursdayCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.thursday
        case (1, 4):
            fridayCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.friday
        case (1, 5):
            saturdayCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.saturday
        case (1, 6):
            sundayCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.sunday
        default:
            offCellOutlet.accessoryType = UITableViewCellAccessoryType.checkmark
            return ScheduleSpeedDayEnum.off
        }
    }
    
    fileprivate func getIndexPathForEnum(_ schedule:ScheduleSpeedDayEnum) -> IndexPath
    {
        switch(schedule)
        {
            case .off:
                return  IndexPath(row: 0, section: 0)
            case .everyDay:
                return IndexPath(row: 1, section: 0)
            case .weekdays:
                return IndexPath(row: 2, section: 0)
            case .weekends:
                return IndexPath(row: 3, section: 0)
            case .monday:
                return IndexPath(row: 0, section: 1)
            case .tuesday:
                return IndexPath(row: 1, section: 1)
            case .wednesday:
                return IndexPath(row: 2, section: 1)
            case .thursday:
                return IndexPath(row: 3, section: 1)
            case .friday:
                return IndexPath(row: 4, section: 1)
            case .saturday:
                return IndexPath(row: 5, section: 1)
            case .sunday:
                return IndexPath(row: 6, section: 1)
            default:
                return IndexPath(row: 0, section: 0)
        }
    }
}
