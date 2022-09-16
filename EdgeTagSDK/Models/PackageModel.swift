//
//  PackageModel.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 02/02/22.
//

import Foundation
import UIKit

struct Result: Codable {
    var result: [Package]
}

struct Package: Codable {
    var package: String
    var rules: Rule
}

struct Rule: Codable {
    var capture: [Capture]
}

struct Capture: Codable {
    var type: String
    var key: String
    var persist: String
}
