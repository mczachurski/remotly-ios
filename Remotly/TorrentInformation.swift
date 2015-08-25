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
    var id:Int64 = 0
    var name:String = ""
    var totalSize:Int64 = 0
    var percentDone:Double = 0.0
    var leftUntilDone:Int64 = 0
    var sizeWhenDone:Int64 = 0
    var peersConnected:Int32 = 0
    var peersSendingToUs:Int32 = 0
    var peersGettingFromUs:Int32 = 0
    var rateDownload:Int64 = 0
    var rateUpload:Int64 = 0
    var isFinished:Bool = false
    var status:Int32 = 0
    var hashString:String = ""
    
    var downloadedPercentDone: Double {
        get {
            let percent = Double(downloadedSize) / Double(totalSize)
            return percent
        }
    }
    
    var downloadedSize: Int64 {
        get {
            let downloaded = sizeWhenDone - leftUntilDone
            return downloaded
        }
    }
    
    var secondsToFinish: Int64 {
        get {
            var seconds:Int64 = 0
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
            let sizeString = FormatHandler.formatSizeUnits(totalSize)
            let downloadedSizeString = FormatHandler.formatSizeUnits(downloadedSize)
            let downloadedPercentDoneString = FormatHandler.roundTwoPlaces(downloadedPercentDone * 100)
            let secondsToFinishString = FormatHandler.formatTime(secondsToFinish)
            
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
            let rateDownloadString = FormatHandler.formatSizeUnits(rateDownload)
            return "DL: \(rateDownloadString)/s"
        }
    }
    
    var uploadInformationValue: String {
        get {
            let rateUpladString = FormatHandler.formatSizeUnits(rateUpload)
            return "UL: \(rateUpladString)/s"
        }
    }
    

}