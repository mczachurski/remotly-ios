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
    static func getFileName(_ fileUrl:URL) -> String
    {
        let urlComponents = URLComponents(url: fileUrl, resolvingAgainstBaseURL: false)
        let items = urlComponents?.queryItems as! [URLQueryItem]
        let dict = NSMutableDictionary()
        for item in items{
            dict.setValue(item.value, forKey: item.name)
        }
        
        if let fileName = dict["dn"] as? String
        {
            let clearFileName = fileName.replacingOccurrences(of: "+", with: " ")
            return clearFileName
        }
        
        return "unknown file name"
    }
}
