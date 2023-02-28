//
//  EdgeTagConfiguration.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 11/02/22.
//

import Foundation
import UIKit

public class EdgeTagConfiguration
{
    public var endPointUrl:String
    public var shouldFetchIDFA:Bool = true
    public var disableConsentCheck:Bool = false
    public var providerInfo:[any BaseProviderInterface]?
   // var abc:Dictionary<any BaseProviderInterface,Bool>?
    
    public class func configuration(withUrl endPointUrl: String, shouldFetchIDFA:Bool = true,disableConsentCheck:Bool = false) -> Self {
        return EdgeTagConfiguration(withUrl: endPointUrl, shouldFetchIDFA: shouldFetchIDFA, disableConsentCheck: disableConsentCheck) as! Self
    }

    public init(withUrl endPointUrl: String , shouldFetchIDFA:Bool = true,disableConsentCheck:Bool = false) {
        self.endPointUrl = endPointUrl
        self.shouldFetchIDFA = shouldFetchIDFA
        self.disableConsentCheck = disableConsentCheck
    }
    
    public init(withUrl endPointUrl: String , shouldFetchIDFA:Bool = true,disableConsentCheck:Bool = false,providerInfo:[any BaseProviderInterface]) {
        self.endPointUrl = endPointUrl
        self.shouldFetchIDFA = shouldFetchIDFA
        self.disableConsentCheck = disableConsentCheck
        self.providerInfo = providerInfo
    }

}
