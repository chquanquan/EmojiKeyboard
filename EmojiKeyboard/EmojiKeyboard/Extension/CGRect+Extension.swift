//
//  CGRect+Extension.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/27.
//  Copyright © 2018年 com.chq. All rights reserved.
//

import UIKit


extension CGRect {
    static var windowsWidth : CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var windowsHeight : CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static var navigationBarHeight: CGFloat {
        return topSafeHeight + 44
    }

    static var bottomSafeHeight: CGFloat {
        return UIDevice.isIphoneX ? iPhoneXBottomSafeHeight : 0
    }

    static var topSafeHeight: CGFloat {
        return UIDevice.isIphoneX ? 44 : 20
    }

    static var iPhoneXBottomSafeHeight: CGFloat {
        return 34
    }
    
}
