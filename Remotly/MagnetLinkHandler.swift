//
//  MagnetLinkHandler.swift
//  Remotly
//
//  Created by Marcin Czachurski on 26.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

class MagnetLinkHander
{
    static func getFileName(fileUrl:NSURL) -> String
    {
        let urlComponents = NSURLComponents(URL: fileUrl, resolvingAgainstBaseURL: false)
        let items = urlComponents?.queryItems
        let dict = NSMutableDictionary()
        for item in items! {
            dict.setValue(item.value, forKey: item.name)
        }
        
        if let fileName = dict["dn"] as? String
        {
            let clearFileName = fileName.stringByReplacingOccurrencesOfString("+", withString: " ")
            return clearFileName
        }
        
        return "unknown file name"
    }
}