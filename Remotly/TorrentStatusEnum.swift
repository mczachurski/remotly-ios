//
//  TorrentStatus.swift
//  Remotly
//
//  Created by Marcin Czachurski on 24.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

enum TorrentStatusEnum:Int32 {
    case paused = 0
    case verifying = 2
    case downloading = 4
    case finished = 6
    case deleting = 8
}
