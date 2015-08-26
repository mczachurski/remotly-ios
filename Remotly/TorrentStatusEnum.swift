//
//  TorrentStatus.swift
//  Remotly
//
//  Created by Marcin Czachurski on 24.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

enum TorrentStatusEnum:Int32 {
    case Paused = 0
    case Verifying = 2
    case Downloading = 4
    case Finished = 6
    case Deleting = 8
}