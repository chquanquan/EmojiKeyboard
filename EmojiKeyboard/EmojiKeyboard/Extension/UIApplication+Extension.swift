//
//  UIApplication+Extension.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/27.
//  Copyright © 2018年 com.chq. All rights reserved.
//

import UIKit

extension UIApplication {
    
    func activityViewController() -> UIViewController {
        
        var normalWindow = self.delegate?.window!
        if normalWindow?.windowLevel != UIWindowLevelNormal {
            for (_,window) in self.windows.enumerated() {
                if window.windowLevel == UIWindowLevelNormal {
                    normalWindow = window
                    break
                }
            }
        }
        return self.nextTopForViewController(inViewController: (normalWindow?.rootViewController)!)
    }
    
    private func nextTopForViewController(inViewController: UIViewController) -> UIViewController {
        
        var newInViewController = inViewController
        while (newInViewController.presentedViewController != nil) {
            newInViewController = newInViewController.presentedViewController!
        }
        
        if newInViewController is UITabBarController {
            let selectedVC = self.nextTopForViewController(inViewController: ((newInViewController as! UITabBarController).selectedViewController)!)
            return selectedVC;
        } else if (newInViewController is UINavigationController) {
            let selectedVC = self.nextTopForViewController(inViewController: ((newInViewController as! UINavigationController).visibleViewController)!)
            return selectedVC
        } else {
            return newInViewController
        }
        
    }
    
}
