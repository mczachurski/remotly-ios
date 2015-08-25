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
    static var sessionId:String!
    var torrentsInformation:[TorrentInformation] = []
    var transmissionUrl:String = ""
    
    init(address:String)
    {
        if(address.rangeOfString("http://", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) == nil)
        {
            transmissionUrl = "http://" + address
        }
        
        transmissionUrl = transmissionUrl + "/transmission/rpc"
    }
    
    func loadTorrents(onCompletion: ((NSError!) -> Void)?)
    {
        torrentsInformation.removeAll(keepCapacity: true)
        loadWithSession(getTorrents, onCompletion: onCompletion)
    }

    func addTorrent(fileUrl:NSURL, isExternal:Bool, onCompletion:((NSError!) -> Void)?)
    {
        var err: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: transmissionUrl)!)
        request.HTTPMethod = "POST"
        request.addValue(TransmissionClient.sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        var requestJson = ""
        
        if(isExternal == true)
        {
            requestJson += "{ \"arguments\": {\"filename\": \""
            requestJson += fileUrl.absoluteString!
            requestJson += "\" }, \"method\": \"torrent-add\", \"tag\": 39693 }"
        }
        else
        {
            let dataContent = NSData(contentsOfURL: fileUrl)
            let base64Content = dataContent?.base64EncodedStringWithOptions(nil)
            
            requestJson += "{ \"arguments\": {\"metainfo\": \""
            requestJson += base64Content!
            requestJson += "\" }, \"method\": \"torrent-add\", \"tag\": 39693 }"
        }
        
        request.HTTPBody = requestJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in

            var datastring = NSString(data:data, encoding:NSUTF8StringEncoding)

            let json:JSON = JSON(data: data)
            
            var result = json["result"].stringValue
            
            if(result != "success")
            {
                let internalError = NSError(domain: "somedomain1", code: 123, userInfo: nil)
            }
            
            if(onCompletion != nil)
            {
                onCompletion!(error)
            }
            
        })
        
        task.resume()
    }
    
    func removeTorrent(torrentId:Int, onCompletion:((NSError!) -> Void)?)
    {
        var err: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: transmissionUrl)!)
        request.HTTPMethod = "POST"
        request.addValue(TransmissionClient.sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        var requestJson = "{ \"arguments\": {\"ids\": [ \(torrentId) ]}, \"method\": \"torrent-remove\", \"tag\": 39693 }"
        request.HTTPBody = requestJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            let json:JSON = JSON(data: data)
            
            var result = json["result"].stringValue
            
            if(result != "success")
            {
                let internalError = NSError(domain: "somedomain1", code: 123, userInfo: nil)
            }
            
            if(onCompletion != nil)
            {
                onCompletion!(error)
            }
            
        })
        
        task.resume()
    }
    
    func reasumeTorrent(torrentId:Int, onCompletion:((NSError!) -> Void)?)
    {
        var err: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: transmissionUrl)!)
        request.HTTPMethod = "POST"
        request.addValue(TransmissionClient.sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        var requestJson = "{ \"arguments\": {\"ids\": [ \(torrentId) ]}, \"method\": \"torrent-start\", \"tag\": 39693 }"
        request.HTTPBody = requestJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            let json:JSON = JSON(data: data)
                        
            var result = json["result"].stringValue
            
            if(result != "success")
            {
                let internalError = NSError(domain: "somedomain1", code: 123, userInfo: nil)
            }
            
            if(onCompletion != nil)
            {
                onCompletion!(error)
            }
            
        })
        
        task.resume()
    }
    
    func pauseTorrent(torrentId:Int, onCompletion:((NSError!) -> Void)?)
    {
        var err: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: transmissionUrl)!)
        request.HTTPMethod = "POST"
        request.addValue(TransmissionClient.sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        var requestJson = "{ \"arguments\": {\"ids\": [ \(torrentId) ]}, \"method\": \"torrent-stop\", \"tag\": 39693 }"
        request.HTTPBody = requestJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            let json:JSON = JSON(data: data)
            
            var result = json["result"].stringValue
            
            if(result != "success")
            {
                let internalError = NSError(domain: "somedomain1", code: 123, userInfo: nil)
            }
            
            if(onCompletion != nil)
            {
                onCompletion!(error)
            }
        })
        
        task.resume()
    }
    
    private func getTorrents(onCompletion: ((NSError!) -> Void)?)
    {
        var err: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: transmissionUrl)!)
        request.HTTPMethod = "POST"
        request.addValue(TransmissionClient.sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        var requestJson = "{ \"arguments\": {\"fields\": [ \"status\",\"id\", \"name\", \"totalSize\", \"files\", \"priorities\", \"percentDone\", \"leftUntilDone\", \"sizeWhenDone\", \"peersConnected\", \"peersSendingToUs\", \"rateDownload\", \"rateUpload\", \"isFinished\", \"peersGettingFromUs\" ]}, \"method\": \"torrent-get\", \"tag\": 39693 }"
        request.HTTPBody = requestJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            let json:JSON = JSON(data: data)

            var torrents = json["arguments"]["torrents"]
            
            for (key: String, subJson: JSON) in torrents
            {
                var torrentInformation = TorrentInformation()
                torrentInformation.id = subJson["id"].intValue
                torrentInformation.status = subJson["status"].intValue
                torrentInformation.name = subJson["name"].stringValue
                torrentInformation.totalSize = subJson["totalSize"].intValue
                torrentInformation.percentDone = subJson["percentDone"].doubleValue
                torrentInformation.leftUntilDone = subJson["leftUntilDone"].intValue
                torrentInformation.sizeWhenDone = subJson["sizeWhenDone"].intValue
                torrentInformation.peersConnected = subJson["peersConnected"].intValue
                torrentInformation.peersSendingToUs = subJson["peersSendingToUs"].intValue
                torrentInformation.rateDownload = subJson["rateDownload"].intValue
                torrentInformation.rateUpload = subJson["rateUpload"].intValue
                torrentInformation.isFinished = subJson["isFinished"].boolValue
                torrentInformation.peersGettingFromUs = subJson["peersGettingFromUs"].intValue
                
                self.torrentsInformation.append(torrentInformation)
            }
            
            onCompletion!(error)
            
        })
        
        task.resume()
    }
    
    private func loadWithSession(loading: ((((NSError!) -> Void)?) -> Void), onCompletion: ((NSError!) -> Void)?)
    {
        if(TransmissionClient.sessionId != nil)
        {
            loading(onCompletion)
            return
        }
        
        var err: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: transmissionUrl)!)
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
                    TransmissionClient.sessionId = httpResponse.allHeaderFields["X-Transmission-Session-Id"] as! String
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