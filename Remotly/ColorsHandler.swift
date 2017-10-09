//
//  ColorsHandler.swift
//  Remotly
//
//  Created by Marcin Czachurski on 25.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation
import UIKit

class ColorsHandler
{
    static func getMainColor() -> UIColor
    {
        return UIColor(red: 231.0/255.0, green: 44.0/255.0, blue: 64.0/255.0, alpha: 1.0)
    }
    
    static func getGrayColor() -> UIColor
    {
        return UIColor(red: 159.0/255.0, green: 158.0/255.0, blue: 168.0/255.0, alpha: 1.0)
    }
    
    static func getNotificationErrorColor() -> UIColor
    {
        return UIColor(red: 183.0/255.0, green: 54.0/255.0, blue: 57.0/255.0, alpha: 0.9)
    }
    
    static func getNotificationSuccessColor() -> UIColor
    {
        return UIColor(red: 19.0/255.0, green: 137.0/255.0, blue: 45.0/255.0, alpha: 0.9)
    }
}