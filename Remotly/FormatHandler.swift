//
//  FormatHandler.swift
//  Remotly
//
//  Created by Marcin Czachurski on 25.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

class FormatHandler
{
    static func roundTwoPlaces(value:Double) -> Double {
        let divisor = pow(10.0, 2.0)
        return round(value * divisor) / divisor
    }
    
    static func formatSizeUnits(size:Int64) -> String
    {
        var sizeString = ""
        if (size >= 1000000000)
        {
            let calculatedSize = Double(size) / 1000000000.0
            sizeString = "\(roundTwoPlaces(calculatedSize)) GB"
        }
        else if (size >= 1000000)
        {
            let calculatedSize = Double(size) / 1000000.0
            sizeString = "\(roundTwoPlaces(calculatedSize)) MB"
        }
        else if (size >= 1000)
        {
            let calculatedSize = Double(size) / 1000.0
            sizeString = "\(roundTwoPlaces(calculatedSize)) KB"
        }
        else if (size > 1)
        {
            sizeString = "\(size) bytes"
        }
        else if (size == 1)
        {
            sizeString = "\(size) byte"
        }
        else
        {
            sizeString = "0 byte"
        }
        
        return sizeString;
    }
    
    static func formatTime(seconds:Int64) -> String
    {
        var timeString = ""
        if (seconds >= 86400)
        {
            let calculatedDays = seconds / 86400
            let calculatedHours = (seconds % 86400) / 3600
            
            var calculatedDaysString = ""
            if(calculatedDays == 1)
            {
                calculatedDaysString = "\(calculatedDays) day"
            }
            else
            {
                calculatedDaysString = "\(calculatedDays) days"
            }
            
            
            timeString = "\(calculatedDaysString) \(calculatedHours) hr"
        }
        else if (seconds >= 3600)
        {
            let calculatedHours = seconds / 3600
            let calculatedMinutes = (seconds % 3600) / 60
            
            timeString = "\(calculatedHours) hr \(calculatedMinutes) min"
        }
        else if (seconds >= 60)
        {
            let calculatedMinutes = seconds / 60
            let calculatedSeconds = seconds % 60
            
            timeString = "\(calculatedMinutes) min \(calculatedSeconds) sec"
        }
        else if (seconds > 0)
        {
            timeString = "\(seconds) sec"
        }
        else
        {
            timeString = "unknown time"
        }
        
        return timeString
    }
    
    static func getHoursAndMinutesFormat(date:NSDate) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        let formattedDate = formatter.stringFromDate(date)
        return formattedDate
    }
}