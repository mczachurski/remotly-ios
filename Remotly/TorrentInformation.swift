//
//  TorrentInformation.swift
//  Remotly
//
//  Created by Marcin Czachurski on 30.07.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

class TorrentInformation
{
    var id:Int = 0
    var name:String = ""
    var totalSize:Int = 0
    var percentDone:Double = 0.0
    var leftUntilDone:Int = 0
    var sizeWhenDone:Int = 0
    var peersConnected:Int = 0
    var peersSendingToUs:Int = 0
    var peersGettingFromUs:Int = 0
    var rateDownload:Int = 0
    var rateUpload:Int = 0
    var isFinished:Bool = false
    var status:Int = 0
    
    var downloadedPercentDone: Double {
        get {
            let percent = Double(downloadedSize) / Double(totalSize)
            return percent
        }
    }
    
    var downloadedSize: Int {
        get {
            let downloaded = sizeWhenDone - leftUntilDone
            return downloaded
        }
    }
    
    var secondsToFinish: Int {
        get {
            var seconds = 0
            if(rateDownload > 0)
            {
                seconds = leftUntilDone / rateDownload
            }
            return seconds
        }
    }
    
    var isDownloading: Bool {
        get {
            var statusEnum = TorrentStatusEnum(rawValue: status)
            return statusEnum == TorrentStatusEnum.Downloading
        }
    }
    
    var isPaused: Bool {
        get {
            var statusEnum = TorrentStatusEnum(rawValue: status)
            return statusEnum == TorrentStatusEnum.Paused
        }
    }
    
    var sizeInformationValue: String {
        get {
            let sizeString = formatSizeUnits(totalSize)
            let downloadedSizeString = formatSizeUnits(downloadedSize)
            let downloadedPercentDoneString = roundTwoPlaces(downloadedPercentDone * 100)
            let secondsToFinishString = formatTime(secondsToFinish)
            
            return "\(downloadedSizeString) of \(sizeString) (\(downloadedPercentDoneString)%) - \(secondsToFinishString)"
        }
    }
    
    var peersInformationValue: String {
        get {
            let peersInformationValue:String
            
            var statusEnum = TorrentStatusEnum(rawValue: status)
            
            if(statusEnum == nil)
            {
                return "unknown status"
            }
            
            switch(statusEnum!)
            {
                case TorrentStatusEnum.Paused:
                    peersInformationValue = "Paused"
                case TorrentStatusEnum.Downloading:
                    peersInformationValue = "Downloading from \(peersSendingToUs) of \(peersConnected) peers"
                case TorrentStatusEnum.Finished:
                    peersInformationValue = "Seeding to \(peersGettingFromUs) of \(peersConnected) peers"
            }

            return peersInformationValue
        }
    }
    
    var downloadInformationValue: String {
        get {
            let rateDownloadString = formatSizeUnits(rateDownload)
            return "DL: \(rateDownloadString)/s"
        }
    }
    
    var uploadInformationValue: String {
        get {
            let rateUpladString = formatSizeUnits(rateUpload)
            return "UL: \(rateUpladString)/s"
        }
    }
    
    func roundTwoPlaces(value:Double) -> Double {
        let divisor = pow(10.0, 2.0)
        return round(value * divisor) / divisor
    }
    
    func formatSizeUnits(size:Int) -> String
    {
        var sizeString = ""
        if (size >= 1000000000)
        {
            var calculatedSize = Double(size) / 1000000000.0
            sizeString = "\(roundTwoPlaces(calculatedSize)) GB"
        }
        else if (size >= 1000000)
        {
            var calculatedSize = Double(size) / 1000000.0
            sizeString = "\(roundTwoPlaces(calculatedSize)) MB"
        }
        else if (size >= 1000)
        {
            var calculatedSize = Double(size) / 1000.0
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
    
    func formatTime(seconds:Int) -> String
    {
        var timeString = ""
        if (seconds >= 86400)
        {
            var calculatedDays = seconds / 86400
            var calculatedHours = (seconds % 86400) / 3600
            
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
            var calculatedHours = seconds / 3600
            var calculatedMinutes = (seconds % 3600) / 60
            
            timeString = "\(calculatedHours) hr \(calculatedMinutes) min"
        }
        else if (seconds >= 60)
        {
            var calculatedMinutes = seconds / 60
            var calculatedSeconds = seconds % 60
            
            timeString = "\(calculatedMinutes) min \(calculatedSeconds) sec"
        }
        else if (seconds > 0)
        {
            timeString = "\(seconds) sec"
        }
        else
        {
            timeString = "unknown"
        }
        
        return timeString
    }
}