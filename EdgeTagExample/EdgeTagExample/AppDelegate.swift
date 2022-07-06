//
//  AppDelegate.swift
//  EdgeTagExample
//
//  Created by Poonam Tiwari on 02/02/22.
//

import UIKit
import EdgeTagSDK
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //EdgeTagConfiguration default values
        //shouldFetchIDFA:true (IDFA needs to be included in info.plist)
        //disableConsentCheck:false


        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
                print("EdgeTag sdk init completed")
            }
            else
            {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })

        let appStartVC = ViewController()
        appStartVC.edgeTagManager = edgeTagManager
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = appStartVC
        self.window?.makeKeyAndVisible()
        return true
    }
}
