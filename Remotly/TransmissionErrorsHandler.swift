//
//  ErrorsHandler.swift
//  Remotly
//
//  Created by Marcin Czachurski on 25.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

let NSTransmissionAddErrorDomain:String = "NSTransmissionAddErrorDomain"
let NSTransmissionRemoveErrorDomain:String = "NSTransmissionRemoveErrorDomain"
let NSTransmissionReasumeErrorDomain:String = "NSTransmissionReasumeErrorDomain"
let NSTransmissionPauseErrorDomain:String = "NSTransmissionPauseErrorDomain"
let NSTransmissionGetErrorDomain:String = "NSTransmissionGetErrorDomain"
let NSTransmissionUnknownErrorDomain:String = "NSTransmissionUnknownErrorDomain"

class TransmissionErrorsHandler
{
    static func createError(errorDomain:String, message:String) -> NSError
    {
        var userInfo = [
            NSLocalizedDescriptionKey: TransmissionErrorsHandler.getUserMessageForErrorDomain(errorDomain),
            NSLocalizedFailureReasonErrorKey: message
        ];
        
        let errorCode = getErrorCodeForErrorDomain(errorDomain)
        let error = NSError(domain: errorDomain, code: errorCode, userInfo: userInfo)
        return error
    }
    
    private static func getUserMessageForErrorDomain(errorDomain:String) -> String
    {
        switch(errorDomain)
        {
            case NSTransmissionAddErrorDomain:
                return "Error during adding new torrent file"
            case NSTransmissionRemoveErrorDomain:
                return "Error during removing torrent file"
            case NSTransmissionReasumeErrorDomain:
                return "Error during reasumig torrent file"
            case NSTransmissionPauseErrorDomain:
                return "Error during pausing torrent file"
            case NSTransmissionGetErrorDomain:
                return "Error during getting torrent files"
            case NSTransmissionUnknownErrorDomain:
                return "Unknown error"
            default:
                return "Unknown error"
        }
    }
    
    private static func getErrorCodeForErrorDomain(errorDomain:String) -> Int
    {
        switch(errorDomain)
        {
        case NSTransmissionAddErrorDomain:
            return 1
        case NSTransmissionRemoveErrorDomain:
            return 2
        case NSTransmissionReasumeErrorDomain:
            return 3
        case NSTransmissionPauseErrorDomain:
            return 4
        case NSTransmissionGetErrorDomain:
            return 5
        case NSTransmissionUnknownErrorDomain:
            return 6
        default:
            return -1
        }
    }
}