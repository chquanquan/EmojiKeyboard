//
//  UIColor+Extension.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/27.
//  Copyright © 2018年 com.chq. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var backgroudColor: UIColor {
        return getRGBColor(240, 240, 255)
    }
    
    static var mainColor: UIColor {
        return UIColor.getRGBColor(81, 45, 168)
    }
    
    static var destructColor: UIColor {
        return getRGBColor(244, 67, 54)
    }
    
    static var textInkGrayColor: UIColor {
        return getRGBColor(172, 182, 183)
    }
    
    static var textBlackColor: UIColor {
        return getRGBColor(37, 37, 45)
    }
    
    static var buttondDisableColor: UIColor {
        return getRGBColor(108, 114, 115)
    }
    
    class func getRGBColor(_ r : CGFloat,_ g : CGFloat,_ b : CGFloat,_ a : CGFloat = 1.0) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
}
