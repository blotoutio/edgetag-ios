//
//  BOAUtilities.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 16/04/22.
//

import Foundation
import UIKit

public class BOAUtilities:NSObject {
    
    static var deviceID:String = ""    
    class func getCurrentTimezoneOffsetInMin() -> Int {

            let timeZone = NSTimeZone.local as NSTimeZone
            let seconds = timeZone.secondsFromGMT
            let offset = seconds / 60
            return offset
        
    }
    
    class func get13DigitNumberObjTimeStamp() -> NSNumber {

            let timeStamp = Int(Date().timeIntervalSince1970 * 1000)
            let timeStampObj = NSNumber(value: timeStamp)
            return timeStampObj
    }
    
    class func get13DigitIntegerTimeStamp() -> Int {

            let timeStamp = Int(Date().timeIntervalSince1970 * 1000)
            return timeStamp
        
    }
    
    class func getMessageID(forEvent eventName: String?) -> String? {

            let eventNameData = eventName?.data(using: .utf8)
            
        return String(format: "%@-%@-%ld", eventNameData?.base64EncodedString(options: []) ?? "", self.getUUIDString() as CVarArg, Int(self.get13DigitIntegerTimeStamp()))

    }
    
    class func currentPlatformCode() -> Int {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 14
        case .pad:
            return 15
        case .tv:
            return 18
        case .carPlay, .unspecified:
            return 60
        default:
            return 0
        }
    }
    
    class func getDeviceId() -> String? {
        
        //This should return the cookiestring we get in the api response
        return deviceID
    }
    
    class func saveDeviceID(cookieStr:String)
    {
        deviceID = cookieStr
    }
    
    
    class func convertTo64CharUUID(_ stringToConvert: String?) -> String? {

            if stringToConvert == nil || (stringToConvert?.count ?? 0) == 0 {
                return stringToConvert
            }
            
            let str = stringToConvert
            let lengths = [NSNumber(value: 16), NSNumber(value: 8), NSNumber(value: 8), NSNumber(value: 8), NSNumber(value: 24)]
            var parts:[AnyHashable] = []
            var startRange = 0
            for i in 0..<lengths.count {
                let range = NSRange(location: startRange, length: (lengths[i]).intValue )
                let stringOfRange = (str! as NSString).substring(with: range)
                parts.append(stringOfRange)
                startRange += (lengths[i]).intValue
            }
            let uuid64Char = (parts as! Array).joined(separator:"-")
            return uuid64Char

    }
    
    static let generateRandomNumberLetters = "0123456789"
    
    class func generateRandomNumber(length:Int)-> String{
        var number = String()
        for _ in 1...length {
            number += "\(Int.random(in: 0...9))"
        }
        return number
    }
    
    class func getUUIDString() -> String {
        let uuid = UUID()
        let uuidStr = uuid.uuidString
        return uuidStr
    }
    
    class func getUUIDString(from uuidStr: String?) -> String? {

        let uuidRef = CFUUIDCreateFromString(kCFAllocatorDefault, uuidStr as CFString?)
        let tempUniqueID:String = CFUUIDCreateString(kCFAllocatorDefault, uuidRef) as String
        
        if tempUniqueID.count <= 0 {

            return uuidStr
        }
        return tempUniqueID
        
    }
}



