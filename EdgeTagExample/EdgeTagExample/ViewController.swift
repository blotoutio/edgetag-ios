//
//  ViewController.swift
//  EdgeTagExample
//
//  Created by Poonam Tiwari on 02/02/22.
//

import UIKit
import EdgeTagSDK
class ViewController: UIViewController {

    var edgeTagManager: EdgeTagManager?

    @objc func addTag() {
        
        self.edgeTagManager?.addTag(withData: ["value":"20.00","currency":"USD"], eventName: "cartEvent", providers: ["all":false,"facebook":true], completion: { success, error in
            if success{
                print("tag sent from client")
            }
            else
            {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
    }

    @objc func giveConsent() {
        self.edgeTagManager?.giveConsentForProviders(consent: ["facebook":false, "smart":false,"all":true], completion: { success, error in
            if success{
                print("consent given from client")
            }
            else
            {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    @objc func sendUserDetails() {
        self.edgeTagManager?.addUserIDGraph(userKey: "email", userValue: "me@domain.com", completion: { success, error in
            if success{
                print("user identifier stored")
            }
            else
            {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    
    @objc func sendData() {
        
        self.edgeTagManager?.addDataIDGraph(idGraph: ["email":"me@abckl.ij","cutomInfo":"Random string entry","numberValue":987.467,"testBool":true,"invalid value":1], completion: { success, error in
            if success{
                print("user data stored")
            }
            else
            {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    @objc func getData() {
        
        self.edgeTagManager?.getDataIDGraph(idGraphKeys: ["cutomInfo","numberValue","testBool","email","invalid value"], completion: { success, error, idGraph in
            if success{
                print("got data \(String(describing: idGraph))")
            }
            else
            {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    @objc func getUserDataKeys() {
        
        self.edgeTagManager?.getUserKeys(completion: { success, error, idGraphKeys in
            if success{
                print("got keys \(String(describing: idGraphKeys))")
            }
            else
            {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createButtons()
        view.backgroundColor = .clear
    }


    func createButtons()
    {
        let button:UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        button.backgroundColor = .lightGray
        button.setTitle("Give Consent", for: .normal)
        button.addTarget(self, action:#selector(self.giveConsent), for: .touchUpInside)
      //  button.addTarget(self, action:#selector(self.allCallsWithIDFAEnabled), for: .touchUpInside)

        self.view.addSubview(button)

        let button2:UIButton = UIButton(frame: CGRect(x: 100, y: 200, width: 200, height: 50))
        button2.backgroundColor = .lightGray
        button2.setTitle("Add Tag", for: .normal)
        button2.addTarget(self, action:#selector(self.addTag), for: .touchUpInside)
        self.view.addSubview(button2)
        
        let button3:UIButton = UIButton(frame: CGRect(x: 100, y: 300, width: 200, height: 50))
        button3.backgroundColor = .lightGray
        button3.setTitle("Send User ID Details", for: .normal)
        button3.addTarget(self, action:#selector(self.sendUserDetails), for: .touchUpInside)
        self.view.addSubview(button3)
        
        let button4:UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 200, height: 50))
        button4.backgroundColor = .lightGray
        button4.setTitle("Send Data", for: .normal)
        button4.addTarget(self, action:#selector(self.sendData), for: .touchUpInside)
        self.view.addSubview(button4)
        
        let button5:UIButton = UIButton(frame: CGRect(x: 100, y: 500, width: 200, height: 50))
        button5.backgroundColor = .lightGray
        button5.setTitle("Get Data", for: .normal)
        button5.addTarget(self, action:#selector(self.getData), for: .touchUpInside)
        self.view.addSubview(button5)
        
        let button6:UIButton = UIButton(frame: CGRect(x: 100, y: 600, width: 200, height: 50))
        button6.backgroundColor = .lightGray
        button6.setTitle("Get user keys", for: .normal)
        button6.addTarget(self, action:#selector(self.getUserDataKeys), for: .touchUpInside)
        self.view.addSubview(button6)
    }
    
    
    @objc func allCallsWithIDFAEnabled()
    {
        
//        let edgeConfiguration = EdgeTagConfiguration(
//            withUrl: "https://sdk-demo-t.edgetag.io",
//            shouldFetchIDFA: true,
//            disableConsentCheck: false
//        )
       // let edgeTagManager = EdgeTagManager.shared
//
        
        // Initialising EdgeTag SDK with IDFA (Advertiser ID) Permissions Enabled
//        edgeTagManager.initEdgeTag(
//          withEdgeTagConfiguration: edgeConfiguration,
//          completion: { success, error in
//            if success{
//                print("SDK initialized successfully")
//            } else {
//                print("Error is \(error?.localizedDescription ?? "")")
//            }
//        })
//        sleep(5)
        
        /*
        -------------------------------------------------------------------------------------
        Please Note : Consent should be called only after SDK Initialization is successful.
        -------------------------------------------------------------------------------------
        */
        // Simple Consent mode, give consent to all providers
        let all = ["all":true]
        edgeTagManager?.giveConsentForProviders(
          consent: all,
          completion: { success, error in
          if success{
              print("Consent given from client")
          } else {
              print("Error is \(error?.localizedDescription ?? "")")
          }
        })
        sleep(5)

        /*
        -------------------------------------------------------------------------------------
        Please Note : User API should be called only after SDK Initialization is successful
        & Consent call is complete.
        -------------------------------------------------------------------------------------
        */
        // It is highly recommended that you send user details to support
        // advanced matching with Facebook conversions.
        edgeTagManager?.addUserIDGraph(
          userKey: "email",
          userValue: "benedict@edgetag.com",
          completion: { success, error in
            if success{
                print("User Info successfully sent")
            } else {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
        sleep(5)
        
        /*
        -------------------------------------------------------------------------------------
        Please Note : Events API should be called only after SDK Initialization is successful
        & Consent call is complete.
        -------------------------------------------------------------------------------------
        */
        // Event with payload that will just be sent to Facebook
        let withData:[String:AnyHashable] = ["value":20.15,"currency":"USD"]
        
        // Here we specify, this event is to be sent only to Facebook
        let providers = ["facebook":true,"all":false]
        edgeTagManager?.addTag(
          withData: withData,
          eventName: "fb_mobile_add_to_cart",
          providers: providers,
          completion: { success, error in
            if success{
                print("Tag sent from client successfully")
            } else {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
        
    }
    
    @objc func allCallsWithIDFADisabled()
    {
        
        
        let edgeConfiguration = EdgeTagConfiguration(
          withUrl: "https://sdk-demo-t.edgetag.io",
          shouldFetchIDFA: false,
          disableConsentCheck: false
        )
        let edgeTagManager = EdgeTagManager.shared
        
        // Initialising Edgetag SDK without IDFA (Advertiser ID) Permissions
        edgeTagManager.initEdgeTag(
          withEdgeTagConfiguration: edgeConfiguration,
          completion: { success, error in
            if success{
                print("SDK initialized successfully")
            } else {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
        sleep(5)

        /*
        -------------------------------------------------------------------------------------
        Please Note : Consent should be called only after SDK Initialization is successful.
        -------------------------------------------------------------------------------------
        */
        // Simple Consent mode, give consent to all providers
        let all = ["all":true]
        edgeTagManager.giveConsentForProviders(
          consent: all,
          completion: { success, error in
            if success{
                print("Consent given from client")
            } else {
                print("Error is \(error?.localizedDescription ?? "")")
            }
          })
        sleep(5)

        /*
        -------------------------------------------------------------------------------------
        Please Note : User API should be called only after SDK Initialization is successful
        & Consent call is complete.
        -------------------------------------------------------------------------------------
        */
        // It is highly recommended that you send user details to support
        // advanced matching with Facebook conversions.
        edgeTagManager.addUserIDGraph(
          userKey: "email",
          userValue: "benedict@edgetag.com",
          completion: { success, error in
            if success{
                print("User Info successfully sent")
            } else {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
        sleep(5)

        /*
        -------------------------------------------------------------------------------------
        Please Note : Events API should be called only after SDK Initialization is successful
        & Consent call is complete.
        -------------------------------------------------------------------------------------
        */
        // Event with payload that will just be sent to Facebook
        let withData:[String:AnyHashable] = ["value":20.15,"currency":"USD"]

        // Here we specify, this event is to be sent only to Facebook
        let providers = ["facebook":true,"all":false]
        edgeTagManager.addTag(
          withData: withData,
          eventName: "fb_mobile_add_to_cart",
          providers: providers,
          completion: { success, error in
            if success{
                print("Tag sent from client successfully")
            } else {
                print("Error is \(error?.localizedDescription ?? "")")
            }
        })
        
    }
        
}
