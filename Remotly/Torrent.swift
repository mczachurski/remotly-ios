//
//  Torrent.swift
//  
//
//  Created by Marcin Czachurski on 25.08.2015.
//
//

import Foundation
import CoreData

class Torrent: NSManagedObject {

    @NSManaged var id: Int64
    @NSManaged var name: String
    @NSManaged var totalSize: Int64
    @NSManaged var percentDone: Double
    @NSManaged var leftUntilDone: Int64
    @NSManaged var sizeWhenDone: Int64
    @NSManaged var peersConnected: Int32
    @NSManaged var peersSendingToUs: Int32
    @NSManaged var peersGettingFromUs: Int32
    @NSManaged var rateDownload: Int64
    @NSManaged var rateUpload: Int64
    @NSManaged var isFinished: Bool
    @NSManaged var status: Int32
    @NSManaged var hashString: String

}
