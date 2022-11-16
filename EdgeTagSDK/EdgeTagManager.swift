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
    
    public func addDataIDGraph(idGraph:Dictionary<String,String>,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        networkManager.addDataIDGraph(idGraph:idGraph, completion: completion)
    }
    
    public func getDataIDGraph(idGraphKeys:[String],completion: @escaping (_ success:Bool, _ error: Error?, _ idGraph:Dictionary<String,String>?) -> Void)
    {
        networkManager.getDataForIDGraphKeys(idGraphKeys:idGraphKeys, completion: completion)
    }
    
    public func getUserKeys(completion: @escaping (_ success:Bool, _ error: Error?, _ idGraphKeys:Array<String>?) -> Void)
    {
        networkManager.getUserKeys( completion: completion)
    }
    
    public func isAdvertiserIdAvailable(completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        networkManager.isIDFAAccessAuthorised(completion: completion)
    }
    
    public func getUserId(completion: @escaping ( _ userId:String) -> Void)
    {
        let userId =  StorageHandler.shared.getCookie()
        completion(userId)
    }
}
