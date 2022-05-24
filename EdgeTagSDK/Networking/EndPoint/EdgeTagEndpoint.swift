//
//  EdgeTagEndpoint.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 02/02/22.
//

import Foundation

public enum NetworkEnvironment {
    case production
    case staging
}

public enum EdgeApi {
    case initEdgeTag(cookieStr :String,disableConsentCheck:Bool? = false)
    case tag(withData: Dictionary<AnyHashable,Any>,eventName:String,providers :Dictionary<String,Bool>,storage :Dictionary<AnyHashable,Any>,userAgent:String,cookieStr :String,pageURL:String)
    case consent(consent: Dictionary<String,Bool>,storage :Dictionary<AnyHashable,Any>,userAgent:String,cookieStr :String,pageURL:String)
    case user(idGraphKey: String,idGraphValue:String,storage :Dictionary<AnyHashable,Any>,userAgent:String,cookieStr :String,pageURL:String)

}

extension EdgeApi: EndPointType {
    var environmentBaseURL : String {
        switch NetworkManager.environment {
        case .production: return StorageHandler.shared.getEndpointURL()//"https://sdk-demo-t.edgetag.io"
        case .staging: return StorageHandler.shared.getEndpointURL()//"https://sdk-demo-t.edgetag.io"
        }
    }

    public var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }

    public var path: String {
        switch self {
        case .initEdgeTag(let cookie,let disableConsentCheck):
            
            if disableConsentCheck == true
            {
               return "init?consentDisabled=true"
            }else{
                return "init"
            }
        case .tag:
            return "tag"
        case .consent:
            return "consent"
        case .user:
            return "user"
        }
    }

    public var httpMethod: HTTPMethod {
        switch self {
        case .initEdgeTag:
            return .get
        case .tag:
            return .post
        case .consent:
            return .post
        case .user:
            return .post
        }
    }

    public var task: HTTPTask {
        switch self {
        case .initEdgeTag(let cookie,let disableConsentCheck):
            if cookie.count > 0
            {
                return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.cookieTypeHeader:cookie])
            }
            else{
                return .request
            }
        case .consent(let consent , let storage , let userAgent, let cookie,let pageURL):
            let bodyParam = [Constants.consentStringParameter:consent , Constants.storageParameter :storage,Constants.userAgentParameter :userAgent,Constants.pageURLParameter:pageURL] as [String : Any]
            return .requestParametersAndHeaders(bodyParameters: bodyParam, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.contentTypeHeader:Constants.jsonHeaderValue,Constants.cookieTypeHeader:cookie])

        case .tag(let data,let eventName,let providers,let storage, let userAgent, let cookie,let pageURL):
            let bodyParam = [Constants.dataNameParameter:data,Constants.eventNameParameter:eventName,Constants.providersParameter:providers ,Constants.storageParameter :storage,Constants.userAgentParameter :userAgent,Constants.pageURLParameter:pageURL] as [String : Any]
            return .requestParametersAndHeaders(bodyParameters: bodyParam, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.contentTypeHeader:Constants.jsonHeaderValue,Constants.cookieTypeHeader:cookie])
            
        case .user(let userKey,let userValue , let storage , let userAgent, let cookie,let pageURL):
            let bodyParam = [Constants.userKeyParameter:userKey,Constants.userValueParameter:userValue , Constants.storageParameter :storage,Constants.userAgentParameter :userAgent,Constants.pageURLParameter:pageURL] as [String : Any]
            return .requestParametersAndHeaders(bodyParameters: bodyParam, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.contentTypeHeader:Constants.jsonHeaderValue,Constants.cookieTypeHeader:cookie])

        }
    }

    public var headers: HTTPHeaders? {
        return nil
    }
}
