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

    @NSManaged var id: Int32
    @NSManaged var name: String
    @NSManaged var totalSize: Int32
    @NSManaged var percentDone: Double
    @NSManaged var leftUntilDone: Int32
    @NSManaged var sizeWhenDone: Int32
    @NSManaged var peersConnected: Int32
    @NSManaged var peersSendingToUs: Int32
    @NSManaged var peersGettingFromUs: Int32
    @NSManaged var rateDownload: Int32
    @NSManaged var rateUpload: Int32
    @NSManaged var isFinished: Bool
    @NSManaged var status: Int32
    @NSManaged var hashString: String

}
