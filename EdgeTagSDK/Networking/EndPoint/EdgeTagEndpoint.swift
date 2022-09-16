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
    case initEdgeTag(cookieStr: String, disableConsentCheck: Bool? = false)
    case tag(withData: [AnyHashable: Any], eventName: String, providers: [String: Bool], storage: [AnyHashable: Any], userAgent: String, cookieStr: String, pageURL: String)
    case consent(consent: [String: Bool], storage: [AnyHashable: Any], userAgent: String, cookieStr: String, pageURL: String)
    case user(idGraphKey: String, idGraphValue: String, storage: [AnyHashable: Any], userAgent: String, cookieStr: String, pageURL: String)
    case data(idGraph: [String: AnyHashable], storage: [AnyHashable: Any], userAgent: String, cookieStr: String, pageURL: String)
    case getData(dataKeys: [String], cookieStr: String)
    case getKeys(cookieStr: String)

}

extension EdgeApi: EndPointType {
    var environmentBaseURL: String {
        switch NetworkManager.environment {
        case .production: return StorageHandler.shared.getEndpointURL()// "https://sdk-demo-t.edgetag.io"
        case .staging: return StorageHandler.shared.getEndpointURL()// "https://sdk-demo-t.edgetag.io"
        }
    }

    public var baseURL: URL? {
        guard let url = URL(string: environmentBaseURL) else { return nil}
        return url
    }

    public var path: String {
        switch self {
        case .initEdgeTag(let cookie, let disableConsentCheck):

            if disableConsentCheck == true {
                return "init?consentDisabled=true"
            } else {
                return "init"
            }
        case .tag:
            return "tag"
        case .consent:
            return "consent"
        case .user:
            return "user"
        case .data:
            return "data"
        case .getData(let dataKeys, let cookieStr):
            let keyStr = getDataKeysString(datakeys: dataKeys)
            return "data?keys=\(keyStr)"
        case .getKeys:
            return "keys"
        }
    }

    func getDataKeysString(datakeys: [String]) -> String {
        let newKeyString = datakeys.joined(separator: ",")
        let urlString = newKeyString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return urlString

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
        case .data:
            return .post
        case .getData:
            return .get
        case .getKeys:
            return .get
        }
    }

    public var task: HTTPTask {
        switch self {
        case .initEdgeTag(let cookie, let disableConsentCheck):
            if cookie.count > 0 {
                return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.cookieTypeHeader: cookie])
            } else {
                return .request
            }
        case .consent(let consent, let storage, let userAgent, let cookie, let pageURL):
            let bodyParam = [Constants.consentStringParameter: consent, Constants.storageParameter: storage,
                             Constants.userAgentParameter: userAgent, Constants.pageURLParameter: pageURL] as [String: Any]
            return .requestParametersAndHeaders(bodyParameters: bodyParam, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.contentTypeHeader: Constants.jsonHeaderValue, Constants.cookieTypeHeader: cookie])

        case .tag(let data, let eventName, let providers, let storage, let userAgent, let cookie, let pageURL):
            let bodyParam = [Constants.dataNameParameter: data, Constants.eventNameParameter: eventName, Constants.providersParameter: providers, Constants.storageParameter: storage, Constants.userAgentParameter: userAgent, Constants.pageURLParameter: pageURL] as [String: Any]
            return .requestParametersAndHeaders(bodyParameters: bodyParam, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.contentTypeHeader: Constants.jsonHeaderValue, Constants.cookieTypeHeader: cookie])

        case .user(let userKey, let userValue, let storage, let userAgent, let cookie, let pageURL):
            let bodyParam = [Constants.userKeyParameter: userKey, Constants.userValueParameter: userValue, Constants.storageParameter: storage, Constants.userAgentParameter: userAgent, Constants.pageURLParameter: pageURL] as [String: Any]
            return .requestParametersAndHeaders(bodyParameters: bodyParam, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.contentTypeHeader: Constants.jsonHeaderValue, Constants.cookieTypeHeader: cookie])

        case .data(let idGraph, let storage, let userAgent, let cookieStr, let pageURL):
            let bodyParam = [Constants.dataParameter: idGraph, Constants.storageParameter: storage, Constants.userAgentParameter: userAgent, Constants.pageURLParameter: pageURL] as [String: Any]
            return .requestParametersAndHeaders(bodyParameters: bodyParam, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.contentTypeHeader: Constants.jsonHeaderValue, Constants.cookieTypeHeader: cookieStr])

        case .getData(let dataKeys, let cookieStr):
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.contentTypeHeader: Constants.jsonHeaderValue, Constants.cookieTypeHeader: cookieStr])

        case .getKeys(let cookieStr):
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: [:], additionHeaders: [Constants.contentTypeHeader: Constants.jsonHeaderValue, Constants.cookieTypeHeader: cookieStr])

        }
    }

    public var headers: HTTPHeaders? {
        return nil
    }
}
