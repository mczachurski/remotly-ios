//
//  TransmissionSession.swift
//  Remotly
//
//  Created by Marcin Czachurski on 27.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

class TransmissionSession
{
    var altSpeedEnabled:Bool = false
    var altSpeedDown:Int32 = 0
    var altSpeedTimeBegin:Int32 = 0
    var altSpeedTimeEnd:Int32 = 0
    var altSpeedTimeEnabled:Bool = false
    var altSpeedTimeDay = ScheduleSpeedDayEnum.Unknown
    var altSpeedUp:Int32 = 0
    var rpcVersion:Double = 0.0
    var speedLimitDown:Int32 = 0
    var speedLimitDownEnabled:Bool = false
    var speedLimitUp:Int32 = 0
    var speedLimitUpEnabled:Bool = false
    var version:String = ""
}