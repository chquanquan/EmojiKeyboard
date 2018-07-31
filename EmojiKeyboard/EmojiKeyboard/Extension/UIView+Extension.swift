//
//  UIView+Extension.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/27.
//  Copyright © 2018年 com.chq. All rights reserved.
//

import UIKit


extension UIView {
    
    var width: CGFloat {
        set {
            var newFrame = frame
            newFrame.size.width = newValue
            frame = newFrame
        }
        get {
            return frame.size.width
        }
    }
    
    var height: CGFloat {
        set {
            var newFrame = frame
            newFrame.size.height = newValue
            frame = newFrame
        }
        get {
            return frame.size.height
        }
    }
    
    var x: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.x = newValue
            frame = newFrame
        }
        get {
            return frame.origin.x
        }
    }
    
    var y: CGFloat {
        set {
            var newFrame = frame
            newFrame.origin.y = newValue
            frame = newFrame
        }
        get {
            return frame.origin.y
        }
    }
    
    func selectedVibrateAnimate() {
        CATransaction.begin()
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = 0.5
        animation.values = [1.1, 0.8, 1.1, 1]
        layer.add(animation, forKey: "vibrateAnimation")
        CATransaction.commit()
    }
    
    
}
