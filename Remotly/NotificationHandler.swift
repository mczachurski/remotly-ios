//
//  NotificationHandler.swift
//  Remotly
//
//  Created by Marcin Czachurski on 26.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation
import BRYXBanner

class NotificationHandler
{
    static func showError(title:String, message:String)
    {
        dispatch_async(dispatch_get_main_queue()) {
            let banner = Banner(title: title, subtitle: message, image: nil, backgroundColor: ColorsHandler.getNotificationErrorColor())
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }
    }
    
    static func showSuccess(title:String, message:String)
    {
        dispatch_async(dispatch_get_main_queue()) {
            let banner = Banner(title: title, subtitle: message, image: nil, backgroundColor: ColorsHandler.getNotificationSuccessColor())
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }
    }
}