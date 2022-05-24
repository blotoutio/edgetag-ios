//
//  EndPointType.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 02/02/22.
//

import Foundation

public protocol EndPointType {
    var baseURL: URL? { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}
