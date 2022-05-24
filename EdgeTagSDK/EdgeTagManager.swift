//
//  EdgeTagManager.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 08/02/22.
//

import Foundation
public struct EdgeTagManager
{
    public static let shared = EdgeTagManager()
    var networkManager: NetworkManager = NetworkManager.shared
    public init() {}

    public func initEdgeTag(withEdgeTagConfiguration:EdgeTagConfiguration,completion: @escaping (_ success:Bool,_ error: Error?) -> Void)
    {
        networkManager.initEdgeTag(withEdgeTagConfiguration: withEdgeTagConfiguration, completion: completion)
    }

    public func giveConsentForProviders(consent:Dictionary<String,Bool>,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        networkManager.giveConsentForProviders(consent: consent, completion: completion)
    }

    public func addTag(withData: Dictionary<AnyHashable,Any>,eventName:String, providers:Dictionary<String,Bool>,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        networkManager.addTag(withData: withData, eventName: eventName, providers: providers, completion: completion)
    }
    
    public func addUserIDGraph(userKey:String,userValue:String,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        networkManager.addUserIDGraph(userKey: userKey, userValue: userValue, completion: completion)
    }
}
