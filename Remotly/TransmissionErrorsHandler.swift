//
//  ErrorsHandler.swift
//  Remotly
//
//  Created by Marcin Czachurski on 25.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

let NSTransmissionErrorDomain:String = "NSTransmissionErrorDomain"

let NSTransmissionAddError:Int = 1
let NSTransmissionRemoveError:Int = 2
let NSTransmissionReasumeError:Int = 3
let NSTransmissionPauseError:Int = 4
let NSTransmissionGetError:Int = 5
let NSTransmissionUnknownError:Int = 6

class TransmissionErrorsHandler
{
    static func createError(errorCode:Int, message:String) -> NSError
    {
        var userInfo = [
            NSLocalizedDescriptionKey: TransmissionErrorsHandler.getUserMessageForErrorCode(errorCode),
            NSLocalizedFailureReasonErrorKey: message
        ];
        
        let error = NSError(domain: NSTransmissionErrorDomain, code: errorCode, userInfo: userInfo)
        return error
    }
    
    private static func getUserMessageForErrorCode(errorCode:Int) -> String
    {
        switch(errorCode)
        {
        case NSTransmissionAddError:
            return "Error during adding new torrent file"
        case NSTransmissionRemoveError:
            return "Error during removing torrent file"
        case NSTransmissionReasumeError:
            return "Error during reasumig torrent file"
        case NSTransmissionPauseError:
            return "Error during pausing torrent file"
        case NSTransmissionGetError:
            return "Error during getting torrent files"
        case NSTransmissionUnknownError:
            return "Unknown error"
        default:
            return "Unknown error"
        }
    }
}