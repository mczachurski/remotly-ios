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
    case Unknown = 0
    case Sunday = 1
    case Monday = 2
    case Tuesday = 4
    case Wednesday = 8
    case Thursday = 16
    case Friday = 32
    case Weekdays = 62
    case Saturday = 64
    case Weekends = 65
    case EveryDay = 127
}