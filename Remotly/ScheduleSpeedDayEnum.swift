//
//  ScheduleSpeedDayEnum.swift
//  Remotly
//
//  Created by Marcin Czachurski on 29.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

enum ScheduleSpeedDayEnum:Int32
{
    case off = 0
    case sunday = 1
    case monday = 2
    case tuesday = 4
    case wednesday = 8
    case thursday = 16
    case friday = 32
    case weekdays = 62
    case saturday = 64
    case weekends = 65
    case everyDay = 127
}
