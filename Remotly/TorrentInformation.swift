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
    var addedDate: TimeInterval = 0
    var files = [FileInfo]()
}
