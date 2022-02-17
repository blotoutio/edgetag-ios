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

    func fetchAdvertisingIdentifier()
    {
            if #available(iOS 14.0, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    switch status {
                    case .authorized:
                        // Tracking authorization dialog was shown and we are authorized
                        let userIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        StorageHandler.shared.saveUserIdentifier(uuidString: userIdentifier)
                        print("authorised \(ASIdentifierManager.shared().advertisingIdentifier.uuidString)")
                    case .denied:
                        print("denied")
                        // Tracking authorization dialog was shown and permission is denied
                    case   .notDetermined:
                        print("notDetermined")
                        // Tracking authorization dialog has not been shown
                    case   .restricted:
                        print("restricted")
                    @unknown default:
                        print("default")
                    }
                })
            }
    }
}
