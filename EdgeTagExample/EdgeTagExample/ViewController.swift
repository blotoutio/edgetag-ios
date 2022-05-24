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
        self.edgeTagManager?.giveConsentForProviders(consent: ["facebook":false, "smart":false,"all":false], completion: { success, error in
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

    override func viewDidLoad() {
        super.viewDidLoad()
        createButtons()
        view.backgroundColor = .clear
    }


    func createButtons()
    {
        let button:UIButton = UIButton(frame: CGRect(x: 100, y: 200, width: 200, height: 50))
        button.backgroundColor = .lightGray
        button.setTitle("Give Consent", for: .normal)
        button.addTarget(self, action:#selector(self.giveConsent), for: .touchUpInside)
        self.view.addSubview(button)

        let button2:UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 200, height: 50))
        button2.backgroundColor = .lightGray
        button2.setTitle("Add Tag", for: .normal)
        button2.addTarget(self, action:#selector(self.addTag), for: .touchUpInside)
        self.view.addSubview(button2)
        
        let button3:UIButton = UIButton(frame: CGRect(x: 100, y: 600, width: 200, height: 50))
        button3.backgroundColor = .lightGray
        button3.setTitle("Send User ID Details", for: .normal)
        button3.addTarget(self, action:#selector(self.sendUserDetails), for: .touchUpInside)
        self.view.addSubview(button3)
    }
}
