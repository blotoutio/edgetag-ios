//
//  BaseProviderInterface.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 17/01/23.
//

import Foundation

public protocol BaseProviderInterface{
    
    func initProvider(withEdgeTagConfiguration:EdgeTagConfiguration,completion: @escaping (_ success:Bool,_ error: Error?) -> Void)
    func tag(withData: Dictionary<AnyHashable,Any>,eventName:String, providers:Dictionary<String,Bool>,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    func load()
    
}
