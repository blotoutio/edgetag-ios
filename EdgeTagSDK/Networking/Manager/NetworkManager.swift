//
//  NetworkManager.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 02/02/22.
//

import Foundation
import WebKit

public class NetworkManager
{
    public static let environment : NetworkEnvironment = .staging
    public let router = Router<EdgeApi>()
    static let shared = NetworkManager()
    var userAgent :String?
    var checkForIDFA:Bool = false

    public enum APIResult<String>{
        case success
        case failure(String)
    }

    enum NetworkResponse:String {
        case success
        case authenticationError = "You need to be authenticated first."
        case badRequest = "Bad request"
        case outdated = "The url you requested is outdated."
        case failed = "Network request failed."
        case noData = "Response returned with no data to decode."
        case unableToDecode = "We could not decode the response."
    }

    public func initEdgeTag(withEdgeTagConfiguration:EdgeTagConfiguration, completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        addObserversToCheckIDFA()
        let useragent = getUserAgent()
        let cookieHeader = StorageHandler.shared.getCookieForHeader()
        self.updateValuesFromConfig(edgeConfig: withEdgeTagConfiguration)

        var disableConsentCheck = false
        if withEdgeTagConfiguration.disableConsentCheck
        {
            disableConsentCheck = true
        }
        
        
        router.request(.initEdgeTag(cookieStr: cookieHeader,disableConsentCheck: disableConsentCheck)) { data, response, error in

            if error != nil {
                completion(false,error)
            }

            if let response = response as? HTTPURLResponse  {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(true,nil)
                        return
                    }
                    do {
                        let cookieName = Constants.tag_user_id
                        if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName }) {
                            StorageHandler.shared.saveCookie(cookieStr: cookie.value)
                        }

                        let jsonDecoder = JSONDecoder.init()
                        let resultObj = try jsonDecoder.decode(Result.self, from: responseData)
                        PackageProviders.shared.parsePackages(resultObj: resultObj)
                        self.completePostInitActivity(edgeConfig: withEdgeTagConfiguration)

                    }catch {
                        print(error)
                    }
                    completion(true,nil)

                case .failure(_):
                    completion(false,nil)
                    break
                }
            }
        }
    }

    func completePostInitActivity(edgeConfig:EdgeTagConfiguration)
    {
        if edgeConfig.disableConsentCheck
        {
            updateConsentForALL()
        }
        self.sendAppInstallEvent()
    }

    func sendAppInstallEvent()
    {
        if !StorageHandler.shared.getAppInstallEventSent()
        {
            PackageProviders.shared.createStorageModelForAPI(consent:nil)
            self.addTag(isSystemEvent:true, withData: [:], eventName: Constants.appInstall, providers: [:]) { success, error in
                if success{
                    StorageHandler.shared.saveAppInstallEventSent()
                }
            }
        }
    }

    func updateValuesFromConfig(edgeConfig:EdgeTagConfiguration)
    {
        StorageHandler.shared.saveEndpointURL(endpointURL: edgeConfig.endPointUrl)

        if edgeConfig.shouldFetchIDFA
        {
            checkForIDFA = true
        }
    }

    func sendInternalConsentForALL()
    {
        let consentValues = ["all":true]
        giveConsentForProviders(consent: consentValues) { success, error in
            if success
            {
                StorageHandler.shared.saveInternalConsentSent()
                StorageHandler.shared.saveConsentValues(consentValues: consentValues)
            }
        }
    }
    
    func updateConsentForALL()
    {
        let consentValues = ["all":true]
        StorageHandler.shared.saveInternalConsentSent()
        StorageHandler.shared.saveConsentValues(consentValues: consentValues)
    }

    public func giveConsentForProviders(consent:Dictionary<String,Bool>,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        let useragent = getUserAgent()
        let storageDict = PackageProviders.shared.createStorageModelForAPI(consent:consent)
        let cookieHeader = StorageHandler.shared.getCookieForHeader()
        let pageURL = PackageProviders.shared.getScreenName()
        router.request(.consent(consent: consent, storage: storageDict, userAgent:useragent, cookieStr: cookieHeader, pageURL: pageURL )) { data, response, error in

            if let response = response as? HTTPURLResponse  {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    StorageHandler.shared.saveConsentValues(consentValues: consent)
                    completion(true,nil)

                case .failure(_):
                    completion(false,error)
                    break
                }
            }
        }
    }


    public func addTag(isSystemEvent:Bool? = false,
        withData: Dictionary<AnyHashable,Any>,eventName:String, providers:Dictionary<String,Bool>,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {

        let taggingAvailable = PackageProviders.shared.isTaggingPossible(tagProviders:providers)
        if !(isSystemEvent ?? false) && !taggingAvailable
        {
            return
        }
        let storageDict = UserDefaults.standard.object(forKey: Constants.storageParameter) ?? [:]
        let useragent = getUserAgent()
        let cookieHeader = StorageHandler.shared.getCookieForHeader()
        let pageURL = PackageProviders.shared.getScreenName()
        router.request(.tag(withData: withData, eventName: eventName, providers: providers, storage: storageDict as! Dictionary<AnyHashable, Any> , userAgent:useragent, cookieStr: cookieHeader, pageURL: pageURL )) { data, response, error in

            if error != nil {
                completion(false,error)
            }

            if let response = response as? HTTPURLResponse  {
                let result = self.handleNetworkResponse(response)
                switch result {

                case .success:
                    completion(true,nil)
                    break
                case .failure(_):
                    completion(false,error)
                    break
                }
            }
        }
    }

    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> APIResult<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }

    func getUserAgent()->String{

        if self.userAgent?.count ?? 0 <= 0 {
            DispatchQueue.main.async {
                self.userAgent = WKWebView().value(forKey: "userAgent") as? String
            }
        }
        return self.userAgent ?? ""
    }

    fileprivate  func addObserversToCheckIDFA() {
        //IDFA check is inaccurate if tested before this point.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    fileprivate  func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc fileprivate func applicationDidBecomeActive() {
        if self.checkForIDFA
        {
            IDFAHandler.shared.fetchAdvertisingIdentifier()
            self.checkForIDFA = false
            removeObservers()
        }
    }
}
