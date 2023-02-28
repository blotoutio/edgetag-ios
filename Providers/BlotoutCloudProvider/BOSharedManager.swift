//
//  BOSharedManager.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 18/04/22.
//

import Foundation

class BOSharedManager:NSObject {
    private var sBOSharedManagerSharedInstance: Any? = nil
    var sessionId: String?
    var currentScreenName: String?
    var referrer: String?
    var deviceID: String?
    static let sharedInstance = BOSharedManager()
    
    override init() {
        super.init()
        deviceID = BOAUtilities.getDeviceId()
        sessionId = String(format: "%ld", Int(BOAUtilities.get13DigitIntegerTimeStamp()))
        currentScreenName = ""
        referrer = ""
    }
    
    class func refreshSession() {
        BOSharedManager.sharedInstance.sessionId = String(format: "%ld", Int(BOAUtilities.get13DigitIntegerTimeStamp()))
    }
}
