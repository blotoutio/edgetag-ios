//
//  ViewController+Extension.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 10/02/22.
//

import Foundation
import UIKit

extension NSObject {
  var className: String {
    return String(describing: type(of: self))
  }

  class var className: String {
    return String(describing: self)
  }
}
extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
