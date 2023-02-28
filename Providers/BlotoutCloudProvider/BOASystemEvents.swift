//
//  BOASystemEvents.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 18/01/23.
//

import Foundation
import UIKit
class BOASystemEvents:NSObject {
    
    class func captureAppLaunchingInfo(withConfiguration launchOptions: [AnyHashable : Any]?) {
        
        
        let previousBuildV1 =  (UserDefaults.standard.object(forKey: BO_BUILD_Previous)as? NSNumber)?.intValue ?? 0
        
        if previousBuildV1 != 0 {
            
            UserDefaults.standard.set(previousBuildV1, forKey: BO_BUILD_Current)
            UserDefaults.standard.removeObject(forKey: BO_BUILD_Previous)
        }
        let previousVersion = UserDefaults.standard.object(forKey:BO_VERSION_KEY) as? String
        let previousBuildV2 = UserDefaults.standard.object(forKey:BO_BUILD_Current) as? String
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if (previousBuildV2 == nil)
        {
            let vcName = UIApplication.shared.topViewController()?.className ?? ""
            
            EdgeTagManager.shared.addTag(withData: [
                "version": currentVersion ?? "",
                "build": currentBuild ?? "",
                "scrn":vcName
            ], eventName: "Application Installed", providers: ["blotoutCloud":true]) { success, error in
                
            }
            
            
        }
        else if (currentBuild != previousBuildV2)
        {
            
            let vcName = UIApplication.shared.topViewController()?.className ?? ""
            
            EdgeTagManager.shared.addTag(withData: [
                "previous_version": previousVersion ?? "",
                "previous_build": previousBuildV2 ?? "",
                "version": currentVersion ?? "",
                "build": currentBuild ?? "",
                "scrn" :vcName
            ], eventName: "Application Updated", providers: ["blotoutCloud":true]) { success, error in
                
            }
        }
        
        
        var referringApplication:String = ""
        if launchOptions?[UIApplication.LaunchOptionsKey.sourceApplication] != nil
        {
            referringApplication = launchOptions?[UIApplication.LaunchOptionsKey.sourceApplication] as? String ?? ""
        }
        
        var urlValue :String = ""
        if launchOptions?[UIApplication.LaunchOptionsKey.url] != nil
        {
            urlValue = launchOptions?[UIApplication.LaunchOptionsKey.url] as? String ?? ""
        }
        let vcName = UIApplication.shared.topViewController()?.className ?? ""
        
        EdgeTagManager.shared.addTag(withData: [
            "from_background": NSNumber(value: false),
            "version": currentVersion ?? "",
            "build": currentBuild ?? "",
            "referring_application": referringApplication,
            "url": urlValue,
            "scrn":vcName
        ], eventName: "Application Opened", providers: ["blotoutCloud":true]) { success, error in
            
        }
        
        UserDefaults.standard.set(currentVersion, forKey: BO_VERSION_KEY)
        UserDefaults.standard.set(currentBuild, forKey: BO_BUILD_Current)
    }
}
