//
//  IDFAHandler.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 11/02/22.
//

import Foundation
import AdSupport
import AppTrackingTransparency

public class IDFAHandler
{
    public static let shared = IDFAHandler()
    
    var idfaRetryCount:Int = 0
    func fetchAdvertisingIdentifier()
    {
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    self.passIDFAValuesToManager(checkForIDFA: false, idfaAccessGranted: true)
                    // Tracking authorization dialog was shown and we are authorized
                    let userIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    StorageHandler.shared.saveUserIdentifier(uuidString: userIdentifier)
                    
                case .denied:
                    self.passIDFAValuesToManager(checkForIDFA: false, idfaAccessGranted: false)
                    // Tracking authorization dialog was shown and permission is denied
                    
                case   .notDetermined:
                    self.idfaRetryCount = self.idfaRetryCount + 1
                    if (self.idfaRetryCount >= 3)
                    {
                        self.passIDFAValuesToManager(checkForIDFA: false, idfaAccessGranted: false)
                        
                    }
                    else{
                        self.passIDFAValuesToManager(checkForIDFA: true, idfaAccessGranted: false)
                        NetworkManager.shared.checkIDFAValue()
                    }
                    // Tracking authorization dialog has not been shown on UI yet
                    
                case   .restricted:
                    self.passIDFAValuesToManager(checkForIDFA: false, idfaAccessGranted: false)
                    
                @unknown default:
                    print("IDFA default")
                }
            })
        }
    }
    
    func passIDFAValuesToManager(checkForIDFA:Bool,idfaAccessGranted:Bool)
    {
        NetworkManager.shared.checkForIDFA = checkForIDFA
        NetworkManager.shared.idfaAccessGranted = idfaAccessGranted
    }
}
