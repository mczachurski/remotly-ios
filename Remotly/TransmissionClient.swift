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
  static var sessionIds:Dictionary<String, String> = Dictionary<String,String>()
  var transmissionUrl:String = ""
  var userName:String = ""
  var password:String = ""
  
  init(address:String, userName:String, password:String)
  {
    prepareTransmissionUrl(address)
    self.userName = userName
    self.password = password
  }
  
  fileprivate func prepareTransmissionUrl(_ address:String)
  {
    if(address.range(of: "http://", options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil) == nil)
    {
      transmissionUrl = "http://" + address
    }
    
    transmissionUrl = transmissionUrl + "/transmission/rpc"
  }
  
  // MARK: Add torrent
  
  func addTorrent(_ fileUrl:URL, isExternal:Bool, onCompletion:((NSError?) -> Void)?)
  {
    let requestJson = addTorrentPrepareJson(fileUrl, isExternal: isExternal)
    addTorrentSendRequest(requestJson, onCompletion: onCompletion)
  }
  
  fileprivate func addTorrentPrepareJson(_ fileUrl:URL, isExternal:Bool) -> String
  {
    var requestJson = ""
    if(isExternal == true)
    {
      requestJson += "{ \"arguments\": {\"filename\": \""
      requestJson += fileUrl.absoluteString
      requestJson += "\" }, \"method\": \"torrent-add\"}"
    }
    else
    {
      let dataContent = try? Data(contentsOf: fileUrl)
      //let base64Content = dataContent?.base64EncodedStringWithOptions(nil)
      let base64Content = dataContent?.base64EncodedString()
      requestJson += "{ \"arguments\": {\"metainfo\": \""
      requestJson += base64Content!
      requestJson += "\" }, \"method\": \"torrent-add\" }"
    }
    
    return requestJson
  }
  
  fileprivate func addTorrentSendRequest(_ requestJson:String, onCompletion:((NSError?) -> Void)?)
  {
    sendRequest(requestJson, completionHandler: { data, response, error -> Void in
      var internalError = error
      if(internalError == nil)
      {
        do {
          let json:JSON = try JSON(data: data!)
          var result = json["result"].stringValue
          
          if(result != "success")
          {
            internalError = TransmissionErrorsHandler.createError(RTTransmissionAddError, message: result)
          }
        } catch let error as NSError {
          print(error)
        }
      }
      onCompletion?(internalError)
    })
  }
  
  // MARK: Remove torrent
  
  func removeTorrent(_ torrentId:Int64, deleteLocalData:Bool, onCompletion:((NSError?) -> Void)?)
  {
    let requestJson = removeTorrentPrepareJson(torrentId, deleteLocalData: deleteLocalData)
    removeTorrentSendRequest(requestJson, onCompletion: onCompletion)
  }
  
  fileprivate func removeTorrentPrepareJson(_ torrentId:Int64, deleteLocalData:Bool) -> String
  {
    let deleteLocalDataValue = deleteLocalData ? "true" : "false"
    let requestJson = "{ \"arguments\": {\"ids\": [ \(torrentId) ], \"delete-local-data\": \(deleteLocalDataValue) }, \"method\": \"torrent-remove\" }"
    return requestJson
  }
  
  fileprivate func removeTorrentSendRequest(_ requestJson:String, onCompletion:((NSError?) -> Void)?)
  {
    sendRequest(requestJson, completionHandler: { data, response, error -> Void in
      var internalError = error
      if(internalError == nil)
      {
        do {
          let json:JSON = try JSON(data: data!)
          var result = json["result"].stringValue
          
          if(result != "success")
          {
            internalError = TransmissionErrorsHandler.createError(RTTransmissionAddError, message: result)
          }
        } catch let error as NSError {
          print(error)
        }
      }
      onCompletion?(internalError)
    })
  }
  
  // MARK: Reasume torrent
  
  func reasumeTorrent(_ torrentId:Int64, onCompletion:((NSError?) -> Void)?)
  {
    let requestJson = reasumeTorrentPrepareJson(torrentId)
    reasumeTorrentSendRequest(requestJson, onCompletion: onCompletion)
  }
  
  fileprivate func reasumeTorrentPrepareJson(_ torrentId:Int64) -> String
  {
    let requestJson = "{ \"arguments\": {\"ids\": [ \(torrentId) ]}, \"method\": \"torrent-start\" }"
    return requestJson
  }
  
  fileprivate func reasumeTorrentSendRequest(_ requestJson:String, onCompletion:((NSError?) -> Void)?)
  {
    sendRequest(requestJson, completionHandler: { data, response, error -> Void in
      var internalError = error
      if(internalError == nil)
      {
        do {
          let json:JSON = try JSON(data: data!)
          var result = json["result"].stringValue
          
          if(result != "success")
          {
            internalError = TransmissionErrorsHandler.createError(RTTransmissionAddError, message: result)
          }
        } catch let error as NSError {
          print(error)
        }
      }
      onCompletion?(internalError)
    })
  }
  
  // MARK: Pause torrent
  
  func pauseTorrent(_ torrentId:Int64, onCompletion:((NSError?) -> Void)?)
  {
    let requestJson = pauseTorrentPrepareJson(torrentId)
    pauseTorrentSendRequest(requestJson, onCompletion: onCompletion)
  }
  
  fileprivate func pauseTorrentPrepareJson(_ torrentId:Int64) -> String
  {
    let requestJson = "{ \"arguments\": {\"ids\": [ \(torrentId) ]}, \"method\": \"torrent-stop\" }"
    return requestJson
  }
  
  fileprivate func pauseTorrentSendRequest(_ requestJson:String, onCompletion:((NSError?) -> Void)?)
  {
    sendRequest(requestJson, completionHandler: { data, response, error -> Void in
      var internalError = error
      if(internalError == nil)
      {
        do {
          let json:JSON = try JSON(data: data!)
          var result = json["result"].stringValue
          
          if(result != "success")
          {
            internalError = TransmissionErrorsHandler.createError(RTTransmissionAddError, message: result)
          }
        } catch let error as NSError {
          print(error)
        }
      }
      onCompletion?(internalError)
    })
  }
  
  // MARK: Get torrents
  
  func getTorrents(_ onCompletion: (([TorrentInformation]?, NSError?) -> Void)?)
  {
    let requestJson = getTorrentsPrepareJson()
    getTorrentsSendRequest(requestJson, onCompletion: onCompletion)
  }
  
  fileprivate func getTorrentsPrepareJson() -> String
  {
    let requestJson = "{ \"arguments\": {\"fields\": [ \"status\",\"id\", \"name\", \"totalSize\", \"files\", \"priorities\", \"percentDone\", \"leftUntilDone\", \"sizeWhenDone\", \"peersConnected\", \"peersSendingToUs\", \"rateDownload\", \"rateUpload\", \"isFinished\", \"peersGettingFromUs\", \"hashString\", \"addedDate\" ]}, \"method\": \"torrent-get\" }"
    return requestJson
  }
  
  fileprivate func getTorrentsSendRequest(_ requestJson:String, onCompletion:(([TorrentInformation]?, NSError?) -> Void)?)
  {
    sendRequest(requestJson, completionHandler: { data, response, error -> Void in
      
      var torrentInformations = [TorrentInformation]()
      var internalError = error
      if(internalError == nil)
      {
        do {
          let json:JSON = try JSON(data: data!)
          var result = json["result"].stringValue
          
          if(result != "success")
          {
            internalError = TransmissionErrorsHandler.createError(RTTransmissionGetError, message: result)
          }
          else
          {
            var torrents = json["arguments"]["torrents"]
            
            for (key: String, subJson: JSON) in torrents
            {
              var torrentInformation = TorrentInformation()
              torrentInformation.id = JSON["id"].int64Value
              torrentInformation.status = JSON["status"].int32Value
              torrentInformation.name = JSON["name"].stringValue
              torrentInformation.totalSize = JSON["totalSize"].int64Value
              torrentInformation.percentDone = JSON["percentDone"].doubleValue
              torrentInformation.leftUntilDone = JSON["leftUntilDone"].int64Value
              torrentInformation.sizeWhenDone = JSON["sizeWhenDone"].int64Value
              torrentInformation.peersConnected = JSON["peersConnected"].int32Value
              torrentInformation.peersSendingToUs = JSON["peersSendingToUs"].int32Value
              torrentInformation.rateDownload = JSON["rateDownload"].int64Value
              torrentInformation.rateUpload = JSON["rateUpload"].int64Value
              torrentInformation.isFinished = JSON["isFinished"].boolValue
              torrentInformation.peersGettingFromUs = JSON["peersGettingFromUs"].int32Value
              torrentInformation.hashString = JSON["hashString"].stringValue
              torrentInformation.addedDate = JSON["addedDate"].doubleValue
              
              
              
              for (key, value) in JSON["files"]{
                //print(key)
                let name = (value["name"].stringValue)
                let completed = (value["bytesCompleted"].numberValue)
                let length = (value["length"].numberValue)
                var percentage = (completed.floatValue) / (length.floatValue)
                percentage = percentage * 100
                //let fileForArray = [value["name"], completed, length, percentage]
                
                //let fileForArray = [name,  completed, length, percentage] as [Any]
                let file = FileInfo()
                file.name = name
                file.completed = Int64(truncating: completed)
                file.length = Int64(truncating: length)
                file.percentage = percentage
                
                torrentInformation.files.append(file)
                //                        torrentInformation.files.adding(value["name"])
                //                        torrentInformation.files.adding(completed as! Double)
                //                        torrentInformation.files.adding(length as! Double)
                //                        torrentInformation.files.adding(percentage as Float)
                //print("FFA: \(fileForArray)")
                //torrentInformation.files.addingObjects(from: fileForArray)
                //print(torrentInformation.files)
                
              }
              
              torrentInformations.append(torrentInformation)
              
            }
          }
        } catch let error as NSError {
          print(error)
        }
      }
      onCompletion?(torrentInformations, internalError)
    })
  }
  
  // MARK: Get transmission session
  
  func getTransmissionSessionInformation(_ onCompletion: ((TransmissionSession, NSError?) -> Void)?)
  {
    let requestJson = getTransmissionSessionInformationPrepareJson()
    getTransmissionSessionInformationSendRequest(requestJson, onCompletion: onCompletion)
  }
  
  fileprivate func getTransmissionSessionInformationPrepareJson() -> String
  {
    let requestJson = "{ \"method\": \"session-get\" }"
    return requestJson
  }
  
  fileprivate func getTransmissionSessionInformationSendRequest(_ requestJson:String, onCompletion:((TransmissionSession, NSError?) -> Void)?)
  {
    sendRequest(requestJson, completionHandler: { data, response, error -> Void in
      
      var transmissionSession = TransmissionSession()
      var internalError = error
      if(internalError == nil)
      {
        do{
          let json:JSON = try JSON(data: data!)
          var result = json["result"].stringValue
          
          if(result != "success")
          {
            internalError = TransmissionErrorsHandler.createError(RTTransmissionGetError, message: result)
          }
          else
          {
            var sessionJson = json["arguments"]
            transmissionSession.altSpeedEnabled = sessionJson["alt-speed-enabled"].boolValue
            transmissionSession.altSpeedDown = sessionJson["alt-speed-down"].int32Value
            transmissionSession.altSpeedTimeBegin = sessionJson["alt-speed-time-begin"].int32Value
            transmissionSession.altSpeedTimeEnd = sessionJson["alt-speed-time-end"].int32Value
            transmissionSession.altSpeedTimeEnabled = sessionJson["alt-speed-time-enabled"].boolValue
            transmissionSession.altSpeedUp = sessionJson["alt-speed-up"].int32Value
            transmissionSession.rpcVersion = sessionJson["rpc-version"].doubleValue
            transmissionSession.speedLimitDown = sessionJson["speed-limit-down"].int32Value
            transmissionSession.speedLimitUp = sessionJson["speed-limit-up"].int32Value
            transmissionSession.speedLimitDownEnabled = sessionJson["speed-limit-down-enabled"].boolValue
            transmissionSession.speedLimitUpEnabled = sessionJson["speed-limit-up-enabled"].boolValue
            transmissionSession.version = sessionJson["version"].stringValue
            
            transmissionSession.altSpeedTimeDay = ScheduleSpeedDayEnum.off
            if(transmissionSession.altSpeedTimeEnabled)
            {
              var speedTimeDay = sessionJson["alt-speed-time-day"].int32Value
              var speedTimeDayEnum = ScheduleSpeedDayEnum(rawValue: speedTimeDay)
              if(speedTimeDayEnum != nil)
              {
                transmissionSession.altSpeedTimeDay = speedTimeDayEnum!
              }
            }
          }
        } catch let errror as NSError {
          print(error)
        }
      }
      onCompletion?(transmissionSession, internalError)
    })
  }
  
  // MARK: Set transmission session
  
  func setTransmissionSession(_ transmissionSession:TransmissionSession, onCompletion:((NSError?) -> Void)?)
  {
    let requestJson = getTransmissionSessionPrepareJson(transmissionSession)
    setTransmissionSessionSendRequest(requestJson, onCompletion: onCompletion)
  }
  
  fileprivate func getTransmissionSessionPrepareJson(_ transmissionSession:TransmissionSession) -> String
  {
    let altSpeedTimeEnabledValue = transmissionSession.altSpeedTimeEnabled ? "true" : "false"
    let speedLimitDownEnabledValue = transmissionSession.speedLimitDownEnabled ? "true" : "false"
    let speedLimitUpEnabledValue = transmissionSession.speedLimitUpEnabled ? "true" : "false"
    
    let requestJson = "{ \"arguments\": {\"alt-speed-down\": \(transmissionSession.altSpeedDown), \"alt-speed-time-begin\": \(transmissionSession.altSpeedTimeBegin), \"alt-speed-time-enabled\": \(altSpeedTimeEnabledValue), \"alt-speed-time-end\": \(transmissionSession.altSpeedTimeEnd), \"alt-speed-time-day\": \(transmissionSession.altSpeedTimeDay.rawValue), \"alt-speed-up\": \(transmissionSession.altSpeedUp), \"speed-limit-down-enabled\": \(speedLimitDownEnabledValue), \"speed-limit-down\": \(transmissionSession.speedLimitDown), \"speed-limit-up-enabled\": \(speedLimitUpEnabledValue), \"speed-limit-up\": \(transmissionSession.speedLimitUp) }, \"method\": \"session-set\" }"
    
    return requestJson
  }
  
  
  fileprivate func setTransmissionSessionSendRequest(_ requestJson:String, onCompletion:((NSError?) -> Void)?)
  {
    sendRequest(requestJson, completionHandler: { data, response, error -> Void in
      var internalError = error
      if(internalError == nil)
      {
        do {
          let json:JSON = try JSON(data: data!)
          var result = json["result"].stringValue
          
          if(result != "success")
          {
            internalError = TransmissionErrorsHandler.createError(RTTransmissionAddError, message: result)
          }
        } catch let error as NSError {
          print(error)
        }
      }
      onCompletion?(internalError)
    })
  }
  // MARK: Change transmission speeds
  
  func setNormalTransmissionSpeed(_ onCompletion:((NSError?) -> Void)?)
  {
    let requestJson = setTransmissionSpeedPrepareJson(false)
    setTransmissionSpeedSendRequest(requestJson, onCompletion: onCompletion)
  }
  
  func setAlternativeTransmissionSpeed(_ onCompletion:((NSError?) -> Void)?)
  {
    let requestJson = setTransmissionSpeedPrepareJson(true)
    setTransmissionSpeedSendRequest(requestJson, onCompletion: onCompletion)
  }
  
  fileprivate func setTransmissionSpeedPrepareJson(_ isAlternative:Bool) -> String
  {
    let isAlternativeValue = isAlternative ? "true" : "false"
    let requestJson = "{ \"arguments\": {\"alt-speed-enabled\": \(isAlternativeValue) }, \"method\": \"session-set\" }"
    return requestJson
  }
  
  fileprivate func setTransmissionSpeedSendRequest(_ requestJson:String, onCompletion:((NSError?) -> Void)?)
  {
    sendRequest(requestJson, completionHandler: { data, response, error -> Void in
      var internalError = error
      if(internalError == nil)
      {
        do {
          let json:JSON = try JSON(data: data!)
          var result = json["result"].stringValue
          
          if(result != "success")
          {
            internalError = TransmissionErrorsHandler.createError(RTTransmissionAddError, message: result)
          }
        } catch let error as NSError {
          print(error)
        }
      }
      onCompletion?(internalError)
    })
  }
  
  // MARK: Sending request
  
  fileprivate func sendRequest(_ requestJson: String, completionHandler: ((Data?, URLResponse?, NSError?) -> Void)?)
  {
    var request = sendRequestPrepareRequest(requestJson) as URLRequest
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
      
      if(error != nil)
      {
        print("error: \(String(describing: error))")
        completionHandler?(data, response, error as NSError?)
      }
      else
      {
        if(self.checkIfErrorIsMissingSessionId(response!))
        {
          // If error was missing session Id we have to do request again (now we should have proper session Id).
          print("Checking if Session Error)")
          let sessionId = self.getSessionIdForServer()
          request.setValue(sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
          
          let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            print("Data: \(String(describing: data))")
            print("Response: \(String(describing: response))")
            print("Error: \(String(describing: error))")
            
            completionHandler?(data, response, error as NSError?)
          })
          
          task.resume();
        }
        else
        {
          completionHandler?(data, response, error as NSError?)
        }
      }
    })
    
    task.resume();
  }
  
  fileprivate func sendRequestPrepareRequest(_ requestJson: String) -> NSMutableURLRequest
  {
    let request = NSMutableURLRequest(url: URL(string: transmissionUrl)!)
    request.httpMethod = "POST"
    var sessionId = getSessionIdForServer()
    if sessionId != nil {
      sessionId = self.getSessionIdForServer()
    } else {
      sessionId = ""
    }
    request.addValue(sessionId!, forHTTPHeaderField: "X-Transmission-Session-Id")
    
    if(!userName.isEmpty && !password.isEmpty)
    {
      let credentials = "\(userName):\(password)"
      let credentialsData = credentials.data(using: String.Encoding.utf8)
      //let authorization = credentialsData?.base64EncodedStringWithOptions(nil)
      let authorization = credentialsData?.base64EncodedString()
      
      request.setValue("Basic \(authorization!)", forHTTPHeaderField: "Authorization")
    }
    
    request.httpBody = requestJson.data(using: String.Encoding.utf8, allowLossyConversion: false)
    
    return request
  }
  
  // MARK: Manage sessions identifiers
  
  fileprivate func getSessionIdForServer() -> String?
  {
    return TransmissionClient.sessionIds[transmissionUrl];
  }
  
  fileprivate func setSessionIdForServer(_ sessionId:String)
  {
    TransmissionClient.sessionIds[transmissionUrl] = sessionId
  }
  
  fileprivate func checkIfErrorIsMissingSessionId(_ response:URLResponse) -> Bool
  {
    let httpResponse = response as! HTTPURLResponse
    if(httpResponse.statusCode == 409)
    {
      let sessionId = httpResponse.allHeaderFields["X-Transmission-Session-Id"] as! String
      self.setSessionIdForServer(sessionId)
      return true
    }
    
    return false
  }
}

