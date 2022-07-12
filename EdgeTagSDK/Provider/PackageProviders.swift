//
//  Providers.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 04/02/22.
//

import Foundation
import UIKit
class PackageProviders{

    static let shared = PackageProviders()
    var providers:[String] = []
    var kvUserDataDictionary:[String:String] = [:]
    var storage:Dictionary<AnyHashable, Any> = [:]
    var consentSettings:Dictionary<String,Bool> = [:]

    func parsePackages(resultObj:Result)
    {
        for package in resultObj.result
        {
            let packageObj :Package = package
            providers.insert(packageObj.package, at: 0)

          //  let packageKey = packageObj.rules.capture.key
           // providerKeys [packageObj.package] = packageKey
            StorageHandler.shared.saveProviderValues(providers:providers)
        }
    }

    func isTaggingPossible(tagProviders:Dictionary<String,Bool>)-> Bool
    {
        var isTaggingPossible:Bool = false
        let consentData = StorageHandler.shared.getConsentValues()

        if tagProviders.count > 0{
            for (key, value) in tagProviders
            {
                let consentDataAllowsTagging:Bool = (consentData.keys.contains(key)) && (consentData[key] == true)
                if ((value && consentDataAllowsTagging) || consentData["all"] == true) {
                    isTaggingPossible = true
                }
            }
        }
        else
        {
            isTaggingPossible = consentData.values.contains(true)
        }
        return isTaggingPossible
    }



    func getScreenName()-> String
    {
        var screenName = ""
        if let topVC  = UIApplication.getTopViewController()
        {
             screenName = topVC.className
        }
        return screenName
    }

    func createStorageModelForAPI(consent:Dictionary<String,Bool>?)-> Dictionary<AnyHashable, Any>
    {
        //update Storage model
        let consentProviders = StorageHandler.shared.getProviderValues()
        let userID = StorageHandler.shared.getUserIdentifier()
        var edgeTagDict:Dictionary<String,AnyHashable> = [Constants.providersParameter:consentProviders]

        //In case user updates consent post init, priority should be given to the new settings
        if consent != nil
        {
            consentSettings = consent!
            edgeTagDict[Constants.consent] = consentSettings
        }
        else if StorageHandler.shared.getInternalConsent()
        {
            consentSettings = ["all":true]
            edgeTagDict[Constants.consent] = consentSettings
        }

        if userID.count > 0
        {
            storage[Constants.data] = [Constants.facebookApp:[Constants.idfa_id:userID]]
        }

        storage[Constants.edgeTag] = edgeTagDict
        StorageHandler.shared.saveStorageValues(storage:storage)
        return storage
    }
    
    func createKVForUserData(kvUserData:Dictionary<String,String>)
    {
        let kvResults = kvUserDataDictionary.merging(kvUserData, uniquingKeysWith: { (_, last) in last })
        kvUserDataDictionary = kvResults
    }
    
    func getKVForUserData() -> Dictionary<String,String>
    {
        print("kv for user \(kvUserDataDictionary)")
        return kvUserDataDictionary
    }
}
