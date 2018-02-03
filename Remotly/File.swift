//
//  File.swift
//  Remotly
//
//  Created by Simon Cain on 2017-11-11.
//  Copyright © 2017 SunLine Technologies. All rights reserved.
//

import Foundation
import CoreData

class File: NSManagedObject {
  @NSManaged var name:String
  @NSManaged var length:Int64
  @NSManaged var bytesCompleted: Int64
  @NSManaged var percentage: Float
  @NSManaged var torrent: Torrent



//convenience init(name: String, length: NSNumber, bytesCompleted: Double, percentage: Float, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext){
//  self.init(entity: entity, insertInto: context)
//  self.name = name
//  self.length = length
//  self.bytesCompleted = bytesCompleted
//  self.percentage = percentage
// }
//  override var hashValue: Int{
//    get {
//      return name.hashValue
//    }
//  }
//  static func ==(lhs: File, rhs: File) -> Bool {
//    return lhs.name == rhs.name && lhs.length == rhs.length
//  }
//  var length: Int64 {
//    get {
//      return length
//    }
//  }
}

