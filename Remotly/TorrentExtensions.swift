//
//  TorrentExtensions.swift
//  Remotly
//
//  Created by Marcin Czachurski on 25.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

extension Torrent
{
    func synchronizeData(torrentFromServer:TorrentInformation)
    {
        self.hashString = torrentFromServer.hashString
        self.id = torrentFromServer.id
        self.isFinished = torrentFromServer.isFinished
        self.leftUntilDone = torrentFromServer.leftUntilDone
        self.name = torrentFromServer.name
        self.peersConnected = torrentFromServer.peersConnected
        self.peersGettingFromUs = torrentFromServer.peersGettingFromUs
        self.peersSendingToUs = torrentFromServer.peersSendingToUs
        self.percentDone = torrentFromServer.percentDone
        self.rateDownload = torrentFromServer.rateDownload
        self.rateUpload = torrentFromServer.rateUpload
        self.sizeWhenDone = torrentFromServer.sizeWhenDone
        self.status = torrentFromServer.status
        self.totalSize = torrentFromServer.totalSize
        self.addedDate = torrentFromServer.addedDate
    }
    
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