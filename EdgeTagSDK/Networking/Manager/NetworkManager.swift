//
//  NetworkManager.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 02/02/22.
//

import Foundation
import WebKit

public enum BaseAPIError: String,Error {
    case invalidURLError = "Incorrect EdgeTagConfiguration URL"
}

public enum UserKeyError : String, Error {
    case invalidKey = "Invalid Key Type: Key does not belong to the permitted list of keys , Permmited keys: email, phone, firstName, lastName, gender, dateOfBirth, country, state, city, zip"
    case sdkUninitialized = "SDK is not initialized"
    case jsonParseErrorInAPIResponse = "Request failed due to parsing error, kindly raise this as an issue"
}

public class NetworkManager
{
    public static let environment : NetworkEnvironment = .staging
    public let router = Router<EdgeApi>()
    static let shared = NetworkManager()
    var userAgent :String?
    var checkForIDFA:Bool = false
    var isSDKInitialized:Bool = false
    
    
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
    var allowedUserKeys: [String] = ["email", "phone", "firstName", "lastName", "gender", "dateOfBirth", "country", "state", "city", "zip"]
    
    
    public func initEdgeTag(withEdgeTagConfiguration:EdgeTagConfiguration, completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        if withEdgeTagConfiguration.endPointUrl.count <= 0
        {
            let error = BaseAPIError.invalidURLError
            completion(false,error)
            print("\(error.rawValue)")
            return
        }
        
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
                    self.isSDKInitialized = true
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
                    self.isSDKInitialized = false
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
        if !isSDKInitialized
        {
            let error = UserKeyError.sdkUninitialized
            completion(false,error)
            print("\(error.rawValue)")
            return
        }
        
        let useragent = getUserAgent()
        let storageDict = PackageProviders.shared.createStorageModelForAPI(consent:consent)
        let updatedStorageDict = getStorageModelWithUserData()
        let cookieHeader = StorageHandler.shared.getCookieForHeader()
        let pageURL = PackageProviders.shared.getScreenName()
        router.request(.consent(consent: consent, storage: updatedStorageDict, userAgent:useragent, cookieStr: cookieHeader, pageURL: pageURL )) { data, response, error in
            
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
    
    func getStorageModelWithUserData()->Dictionary<AnyHashable, Any>
    {
        var storageDict = StorageHandler.shared.getStorageValues()
        let userDataKV = PackageProviders.shared.getKVForUserData()
        if userDataKV.keys.count > 0{
            storageDict["kv"] = userDataKV
        }   
        return storageDict
    }
    
    public func addTag(isSystemEvent:Bool? = false,
                       withData: Dictionary<AnyHashable,Any>,eventName:String, providers:Dictionary<String,Bool>,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        if !isSDKInitialized
        {
            let error = UserKeyError.sdkUninitialized
            completion(false,error)
            print("\(error.rawValue)")
            return
        }
        
        let taggingAvailable = PackageProviders.shared.isTaggingPossible(tagProviders:providers)
        if !(isSystemEvent ?? false) && !taggingAvailable
        {
            return
        }
        let updatedStorageDict = getStorageModelWithUserData()
        let useragent = getUserAgent()
        let cookieHeader = StorageHandler.shared.getCookieForHeader()
        let pageURL = PackageProviders.shared.getScreenName()
        router.request(.tag(withData: withData, eventName: eventName, providers: providers, storage: updatedStorageDict, userAgent:useragent, cookieStr: cookieHeader, pageURL: pageURL )) { data, response, error in
            
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
    
    public func addUserIDGraph(userKey:String,userValue:String,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        if (!allowedUserKeys.contains(userKey))
        {
            let error :Error = UserKeyError.invalidKey
            completion(false,error)
            return
        }
        else if !isSDKInitialized
        {
            let error = UserKeyError.sdkUninitialized
            completion(false,error)
            print("\(error.rawValue)")
            return
        }
        
        let useragent = getUserAgent()
        PackageProviders.shared.createKVForUserData(kvUserData: [userKey:userValue])
        let updatedStorageDict = getStorageModelWithUserData()
        let cookieHeader = StorageHandler.shared.getCookieForHeader()
        let pageURL = PackageProviders.shared.getScreenName()
        
        router.request(.user(idGraphKey: userKey, idGraphValue: userValue, storage: updatedStorageDict, Any>, userAgent: useragent, cookieStr: cookieHeader, pageURL: pageURL)) { data, response, error in
            
            if let response = response as? HTTPURLResponse  {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    print("user id graph api success")
                    completion(true,nil)
                    break
                case .failure(_):
                    completion(false,error)
                    break
                }
            }
        }
    }

    public func addDataIDGraph(idGraph:Dictionary<String,String>,completion: @escaping (_ success:Bool, _ error: Error?) -> Void)
    {
        if !isSDKInitialized
        {
            let error = UserKeyError.sdkUninitialized
            completion(false,error)
            print("\(error.rawValue)")
            return
        }
        
        let useragent = getUserAgent()
        PackageProviders.shared.createKVForUserData(kvUserData: idGraph)

        let updatedStorageDict = getStorageModelWithUserData()
        let cookieHeader = StorageHandler.shared.getCookieForHeader()
        let pageURL = PackageProviders.shared.getScreenName()
        
        router.request(.data(idGraph: idGraph, storage: updatedStorageDict, Any>, userAgent: useragent, cookieStr: cookieHeader, pageURL: pageURL)) { data, response, error in
            
            if let response = response as? HTTPURLResponse  {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    print("data id graph api success")
                    completion(true,nil)
                    break
                case .failure(_):
                    completion(false,error)
                    break
                }
            }
        }
    }
    
    public func getDataForIDGraphKeys(idGraphKeys:Array<String>,completion: @escaping (_ success:Bool, _ error: Error?, _ idGraph:Dictionary<String,String>?) -> Void)
    {
        if !isSDKInitialized
        {
            let error = UserKeyError.sdkUninitialized
            completion(false,error,nil)
            print("\(error.rawValue)")
            return
        }
        
        let cookieHeader = StorageHandler.shared.getCookieForHeader()
        
        router.request(.getData(dataKeys: idGraphKeys, cookieStr: cookieHeader)) { data, response, error in
            
            if let response = response as? HTTPURLResponse  {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    print("data id graph api success")
                    if data != nil{
                        do {
                            let jsonDict =  try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyHashable]
                            if let jsonResultObj = jsonDict?["result"]
                            {
                                completion(true,nil,jsonResultObj as? Dictionary<String, String>)
                            }
                            else
                            {
                                completion(true,nil,[:])
                            }
                        } catch {
                            let error :Error = UserKeyError.jsonParseErrorInAPIResponse
                            completion(false,error,[:])
                            print("Error is :\(error.localizedDescription)")
                        }
                    }
                    else
                    {
                        completion(true,nil,[:])
                    }
                    break
                case .failure(_):
                    completion(false,error,[:])
                    break
                }
            }
        }
    }
    
    public func getUserKeys(completion: @escaping (_ success:Bool, _ error: Error?, _ idGraphKeys:Array<String>?) -> Void)
    {
        if !isSDKInitialized
        {
            let error = UserKeyError.sdkUninitialized
            completion(false,error,nil)
            print("\(error.rawValue)")
            return
        }
        let cookieHeader = StorageHandler.shared.getCookieForHeader()
        
        router.request(.getKeys(cookieStr: cookieHeader)) { data, response, error in
            
            if let response = response as? HTTPURLResponse  {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    print("data id graph api success")
                    if data != nil{
                        do {
                            let jsonDict =  try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyHashable]
                            let userKeys:[String] = jsonDict?["result"] as? [String] ?? []
                            completion(true,nil,userKeys)
                        } catch {
                            let error :Error = UserKeyError.jsonParseErrorInAPIResponse
                            completion(false,error,[])
                            print(error.localizedDescription)
                        }
                    }
                    else{
                        completion(true,nil,[])
                    }
                    break
                case .failure(_):
                    completion(false,error,[])
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

extension UserKeyError:LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case .invalidKey :
            return "Key does not belong to the permitted list of keys , Permmited keys: email, phone, firstName, lastName, gender, dateOfBirth, country, state, city, zip"
        case .sdkUninitialized :
            return "SDK is not initialized"
        case .jsonParseErrorInAPIResponse :
            return "Request failed due to parsing error, kindly raise this as an issue"
        }
    }
}
