//
//  StorageHandler.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 11/02/22.
//

import Foundation
class StorageHandler{
    public static let shared = StorageHandler()

    func saveEndpointURL(endpointURL:String)
    {
        UserDefaults.standard.set(endpointURL, forKey: Constants.EndpointURL)
    }

    func getEndpointURL()->String
    {
        return UserDefaults.standard.object(forKey: Constants.EndpointURL) as? String ?? ""
    }

    func saveProviderValues(providers:[String])
    {
        UserDefaults.standard.set(providers, forKey: Constants.providersParameter)
    }

    func getProviderValues()->[String]
    {
        return UserDefaults.standard.object(forKey: Constants.providersParameter) as? [String] ?? []
    }

    func saveStorageValues(storage:Dictionary<AnyHashable, Any>)
    {
        UserDefaults.standard.set(storage, forKey: Constants.storageParameter)
    }

    func getStorageValues()->Dictionary<AnyHashable, Any>
    {
        return UserDefaults.standard.object(forKey: Constants.storageParameter) as? Dictionary<AnyHashable, Any> ?? [:]
    }

    func saveConsentValues(consentValues:Dictionary<String,Bool>)
    {
        UserDefaults.standard.set(consentValues, forKey: Constants.consent)
    }

    func getConsentValues()->Dictionary<String,Bool>
    {
        return UserDefaults.standard.object(forKey: Constants.consent) as? Dictionary<String,Bool> ?? [:]
    }

    func saveUserIdentifier(uuidString:String)
    {
        UserDefaults.standard.set(uuidString, forKey: Constants.UserIdentifier)
    }

    func getUserIdentifier()->String
    {
        return UserDefaults.standard.object(forKey: Constants.UserIdentifier) as? String ?? ""
    }

    func saveAppInstallEventSent()
    {
        UserDefaults.standard.set(true, forKey: Constants.appInstall)
    }

    func getAppInstallEventSent()->Bool
    {
        return UserDefaults.standard.bool(forKey: Constants.appInstall)
    }

    func saveInternalConsentSent()
    {
        UserDefaults.standard.set(true, forKey: Constants.InternalConsent)
    }

    func getInternalConsent()->Bool
    {
        return UserDefaults.standard.bool(forKey: Constants.InternalConsent)
    }

    func saveCookie(cookieStr:String)
    {
        UserDefaults.standard.set(cookieStr, forKey:Constants.tag_user_id)
    }

    func getCookieForHeader()->String
    {
        var cookieStr:String = ""
        if let cookieValue = UserDefaults.standard.object(forKey: Constants.tag_user_id) as? String
        {
            cookieStr = Constants.tag_user_id + "=" + cookieValue
        }
        return cookieStr
    }

    func getCookie()->String
    {
       return UserDefaults.standard.object(forKey: Constants.tag_user_id) as? String ?? ""
    }
}
