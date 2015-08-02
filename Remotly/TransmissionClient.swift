//
//  TransmissionClient.swift
//  Remotly
//
//  Created by Marcin Czachurski on 30.07.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class TransmissionClient
{
    var sessionId:String!
    var torrentsInformation:[TorrentInformation] = []
    
    func loadTorrents(onCompletion: ((NSError!) -> Void)?)
    {
        loadWithSession(getTorrents, onCompletion: onCompletion)
    }
    
    private func getTorrents(onCompletion: ((NSError!) -> Void)?)
    {
        var err: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:9091/transmission/rpc")!)
        request.HTTPMethod = "POST"
        request.addValue(sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        var requestJson = "{ \"arguments\": {\"fields\": [ \"status\",\"id\", \"name\", \"totalSize\", \"files\", \"priorities\" ]}, \"method\": \"torrent-get\", \"tag\": 39693 }"
        request.HTTPBody = requestJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            let json:JSON = JSON(data: data)

            var torrents = json["arguments"]["torrents"]
            
            for (key: String, subJson: JSON) in torrents
            {
                var torrentInformation = TorrentInformation()
                torrentInformation.name = subJson["name"].stringValue
                
                self.torrentsInformation.append(torrentInformation)
            }
            
            onCompletion!(error)
            
        })
        
        task.resume()
    }
    
    private func loadWithSession(loading: ((((NSError!) -> Void)?) -> Void), onCompletion: ((NSError!) -> Void)?)
    {
        if(sessionId != nil)
        {
            loading(onCompletion)
            return
        }
        
        var err: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:9091/transmission/rpc")!)
        request.HTTPMethod = "POST"
        
        let requestBody = [""]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: nil, error: &err)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            
            if(error != nil)
            {
                onCompletion!(error)
                return
            }
            
            if(response != nil)
            {
                var httpResponse = response as! NSHTTPURLResponse
                if(httpResponse.statusCode == 409)
                {
                    self.sessionId = httpResponse.allHeaderFields["X-Transmission-Session-Id"] as! String
                    loading(onCompletion)
                    return
                }
                else
                {
                    let internalError = NSError(domain: "somedomain1", code: 123, userInfo: nil)
                    onCompletion!(internalError)
                }
            }
            
            let internalError = NSError(domain: "somedomain2", code: 123, userInfo: nil)
            onCompletion!(internalError)
        })
        
        task.resume()
    }
}