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
    
    func getScreenName(completion: @escaping (String) -> () )
    {
        var screenName = ""
        var topVC:UIViewController?
        DispatchQueue.main.async {
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
            topVC  =  keyWindow?.rootViewController?.topMostViewController()
            if topVC != nil
            {
                screenName = NSStringFromClass(topVC!.classForCoder)
                let arr = screenName.components(separatedBy: ".")
                screenName = arr.last ?? screenName
            }
            completion(screenName)
        }
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
        return kvUserDataDictionary
    }
    
    func getEventIdAndData(fromData:Dictionary<AnyHashable,Any>,eventName:String)->Dictionary<AnyHashable,Any>
    {
        var eventId = ""
        var dataDict = fromData
        if fromData.keys .contains("eventId")
        {
            eventId = fromData["eventId"] as! String
            dataDict.removeValue(forKey: "eventId")
        }
        else
        {
            eventId = generateEventID(eventName: eventName)
        }
        let timeStamp = Int64(round(NSDate().timeIntervalSince1970))
        return ["data":dataDict,"eventId":eventId,"timestamp":"\(timeStamp)"]
    }
    
    func generateEventID(eventName:String)->String
    {
        let eventBase64 = eventName.data(using: .utf8)?.base64EncodedString() ?? ""
        let uuid = UUID().uuidString
        let timeInterval = Int64(round(NSDate().timeIntervalSince1970))
        let eventId = "\(eventBase64)-\(uuid)-\(timeInterval)"
        return eventId
    }
}
