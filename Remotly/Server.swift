//
//  Server.swift
//  
//
//  Created by Marcin Czachurski on 25.08.2015.
//
//

import Foundation
import CoreData

class Server: NSManagedObject {

    @NSManaged var address: String
    @NSManaged var name: String
    @NSManaged var password: String
    @NSManaged var userName: String
    @NSManaged var torrents: NSSet

}
