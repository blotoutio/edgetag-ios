//
//  ViewControllerExtension.swift
//  EdgeTagSDK
//
//  Created by Poonam Tiwari on 19/01/23.
//

import Foundation
import UIKit


class ScreenCapture {
    public static let shared = ScreenCapture()
    
    init() {
        swizzleViewMethods()
    }
    
    internal func swizzleViewMethods() {
        swizzle(forClass: UIViewController.self,
                original: #selector(UIViewController.viewDidAppear(_:)),
                new: #selector(UIViewController.bo__viewDidAppear)
        )
        
        swizzle(forClass: UIViewController.self,
                original: #selector(UIViewController.viewDidDisappear(_:)),
                new: #selector(UIViewController.bo__viewDidDisappear)
        )
    }
    private func swizzle(forClass: AnyClass, original: Selector, new: Selector) {
        guard let originalMethod = class_getInstanceMethod(forClass, original) else { return }
        guard let swizzledMethod = class_getInstanceMethod(forClass, new) else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIViewController {
    
    
    @objc internal func bo__viewDidAppear(animated: Bool) {
        bo__viewDidAppear(animated: animated)
        let vcName = UIApplication.shared.topViewController()?.className ?? ""
        BlotoutCloud.shared.tag(withData: ["eventType" : "system","scrn":vcName], eventName: BO_VISIBILITY_VISIBLE, providers: [blotoutProvider:true]) { success, error in
        }
    }
    
    @objc internal func bo__viewDidDisappear(animated: Bool) {
        bo__viewDidDisappear(animated: animated)
        let vcName = UIApplication.shared.topViewController()?.className ?? ""

        BlotoutCloud.shared.tag(withData: ["eventType" : "system","scrn":vcName], eventName: BO_VISIBILITY_HIDDEN, providers: [blotoutProvider:true]) { success, error in
        }
    }
}

extension UIApplication {
    func topViewController() -> UIViewController? {
        var topViewController: UIViewController? = nil
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        if window.isKeyWindow {
                            topViewController = window.rootViewController
                        }
                    }
                }
            }
        } else {
            topViewController = keyWindow?.rootViewController
        }
        while true {
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            } else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            } else {
                // Handle any other third party container in `else if` if required
                break
            }
        }
        return topViewController
    }
}
