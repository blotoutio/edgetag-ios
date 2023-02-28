//
//  BlotoutCloud.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 17/01/23.
//

import UIKit
import AppTrackingTransparency
import AdSupport

public class BlotoutCloud: BlotoutAnalyticsInterface {
    
    public static let shared = BlotoutCloud()
    var isSDKInitialised:Bool = false
    var screenTracking:ScreenCapture?
    func enableBlotoutCloudSDK(enabled: Bool) {
    }
    
    public func initProvider(withEdgeTagConfiguration: EdgeTagConfiguration, completion: @escaping (Bool, Error?) -> Void) {
        registerForSystemEvents()
        checkForAppInstallorUpgrade()
    }
    
    public func tag(withData: Dictionary<AnyHashable, Any>, eventName: String, providers: Dictionary<String, Bool>, completion: @escaping (Bool, Error?) -> Void) {
        //All events sent from BlotoutAnalyticsInterface should be marked as system events true
        let blotoutDict = [blotoutProvider:withData]
        EdgeTagManager.shared.addTag(isSystemEvent:true,withProviderData:blotoutDict, withData: [:], eventName: eventName, providers: providers, completion: completion)
    }
    
    public func load() {
        // do nothing for now
    }
    
    func registerForSystemEvents()
    {
        registerApplicationStates()
        checkAppTrackingStatus()
        screenTracking = ScreenCapture.shared
    }
    
    func checkForAppInstallorUpgrade()
    {
        
        self.tag(withData: [
            "eventType": "system"
        ], eventName: BO_SDK_START, providers: [blotoutProvider:true]) { success, error in
            
        }
        if UserDefaults.standard.object(forKey: "SDKExists") != nil {
          //Key exists, send tag for app open
            let vcName = UIApplication.shared.topViewController()?.className ?? ""

            self.tag(withData: [
                "eventType": "system",
                "scrn":vcName
            ], eventName: BO_APPLICATION_OPENED, providers: [blotoutProvider:true]) { success, error in
                
            }
        }
        else
        {
            //key doesnt exist send tag for app install
            let vcName = UIApplication.shared.topViewController()?.className ?? ""

            self.tag(withData: [
                "eventType": "system",
                "scrn":vcName
            ], eventName: BO_APPLICATION_INSTALLED, providers: [blotoutProvider:true]) { success, error in
                UserDefaults.standard.set(true, forKey: "SDKExists")
            }
        }
    }
    
    func registerApplicationStates() {
        // Attach to application state change hooks
        let nc = NotificationCenter.default
        for name in [
            UIApplication.didEnterBackgroundNotification,
            UIApplication.didFinishLaunchingNotification,
            UIApplication.willEnterForegroundNotification,
            UIApplication.willTerminateNotification,
            UIApplication.willResignActiveNotification,
            UIApplication.didBecomeActiveNotification]
        {
            guard let name = name.rawValue as? String else {
                continue
            }
            nc.addObserver(self, selector: #selector(handleAppStateNotification(_:)), name: NSNotification.Name(name), object: nil)
        }
    }
    
    @objc func handleAppStateNotification(_ note: Notification?) {
        if note?.name == UIApplication.didFinishLaunchingNotification {
            //TODO:send tag with this
             _applicationDidFinishLaunching(withOptions: note?.userInfo)
        }
        else  if note?.name == UIApplication.willEnterForegroundNotification {
            //TODO:send tag with this
             _applicationWillEnterForeground()
        }
        else if note?.name == UIApplication.didEnterBackgroundNotification {
            //TODO:send tag with this
             _applicationDidEnterBackground()
        } else if note?.name == UIApplication.willTerminateNotification {
            //TODO:send tag with this
            // _applicationWillTerminate()
        }
    }
    
    func checkAppTrackingStatus() {
        
        //            if !isEnabled {
        //                return
        //            }
        //            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {
        //
        //                let sdkManifesCtrl = BOASDKManifestController.sharedInstance
        //                if !sdkManifesCtrl.isSystemEventEnabled(BO_APP_TRACKING) {
        //                    return
        //                }
        
        
        var statusString = ""
        var idfaString = ""
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            switch status {
            case .authorized:
                statusString = "Authorized"
                idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            case .denied:
                statusString = "Denied"
            case .restricted:
                statusString = "Restricted"
            case .notDetermined:
                statusString = "Not Determined"
            default:
                statusString = "Unknown"
                
            }
        }else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                statusString = "Authorized"
                idfaString =  ASIdentifierManager.shared().advertisingIdentifier.uuidString
                
            } else {
                statusString = "Denied"
            }
        }

        let vcName = UIApplication.shared.topViewController()?.className ?? ""

        self.tag(withData: [
            "status": statusString,
            "idfa": idfaString,
            "eventType": "system",
            "scrn":vcName
        ], eventName: "App Tracking", providers: [blotoutProvider:true]) { success, error in
            
        }
    }
    
    func continueUserActivity(activity: NSUserActivity) {

        var properties = [AnyHashable : AnyHashable](minimumCapacity: activity.userInfo?.count ?? 0 + 2)
        
        if activity.userInfo != nil
        {
            properties = activity.userInfo as NSDictionary? as! [String: AnyHashable]
        }
        else
        {
            properties = [:]
        }

        properties["url"] = activity.webpageURL?.absoluteString ?? ""
        properties["title"] = activity.title ?? ""
        properties ["eventType"] = "system"
        let vcName = UIApplication.shared.topViewController()?.className ?? ""

        properties["scrn"] = vcName
        self.tag(withData: properties, eventName: "Deep Link Opened", providers: [blotoutProvider:true]) { success, error in
            
        }
        
    }
    

    
    func _applicationDidFinishLaunching(withOptions launchOptions: [AnyHashable : Any]?) {
           
             BOASystemEvents.captureAppLaunchingInfo(withConfiguration: launchOptions)
    }
    
    func _applicationWillEnterForeground() {

        let vcName = UIApplication.shared.topViewController()//BOAUtilities.topViewController()?.className ?? ""

        self.tag(withData: [
            "from_background": NSNumber(value: true),
            "eventType" : "system",
            "scrn" :vcName
        ], eventName: "Application Opened", providers: [blotoutProvider:true]) {success, error in
        }
        
    }
    
    func _applicationDidEnterBackground() {

        let vcName = UIApplication.shared.topViewController()?.className ?? ""
        self.tag(withData: ["eventType" : "system", "scrn" :vcName], eventName: "Application Backgrounded", providers:[blotoutProvider:true] , completion: {success, error in
        })
    }
}
