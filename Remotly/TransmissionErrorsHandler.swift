//
//  ErrorsHandler.swift
//  Remotly
//
//  Created by Marcin Czachurski on 25.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation

let RTTransmissionErrorDomain:String = "RTTransmissionErrorDomain"

let RTTransmissionUnknownError:Int = -1
let RTTransmissionAddError:Int = 1
let RTTransmissionRemoveError:Int = 2
let RTTransmissionReasumeError:Int = 3
let RTTransmissionPauseError:Int = 4
let RTTransmissionGetError:Int = 5
let RTTransmissionSetSessionError:Int = 6
let RTTransmissionSetAlternativeSpeedLimitError:Int = 7

class TransmissionErrorsHandler
{
    static func createError(errorCode:Int, message:String) -> NSError
    {
        var userInfo = [
            NSLocalizedDescriptionKey: TransmissionErrorsHandler.getUserMessageForErrorCode(errorCode),
            NSLocalizedFailureReasonErrorKey: message
        ];
        
        let error = NSError(domain: RTTransmissionErrorDomain, code: errorCode, userInfo: userInfo)
        return error
    }
    
    private static func getUserMessageForErrorCode(errorCode:Int) -> String
    {
        switch(errorCode)
        {
        case RTTransmissionAddError:
            return "Error during adding new torrent file"
        case RTTransmissionRemoveError:
            return "Error during removing torrent file"
        case RTTransmissionReasumeError:
            return "Error during reasumig torrent file"
        case RTTransmissionPauseError:
            return "Error during pausing torrent file"
        case RTTransmissionGetError:
            return "Error during getting torrent files"
        case RTTransmissionUnknownError:
            return "Unknown error"
        default:
            return "Unknown error"
        }
    }
}