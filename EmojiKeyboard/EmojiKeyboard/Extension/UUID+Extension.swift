//
//  UUID+Extension.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/27.
//  Copyright © 2018年 com.chq. All rights reserved.
//

import Foundation

extension UUID {
    static var string : String {
        get {
            let uuid: String = Foundation.UUID().uuidString
            return uuid.replacingOccurrences(of: "-", with: "")
        }
    }
}
