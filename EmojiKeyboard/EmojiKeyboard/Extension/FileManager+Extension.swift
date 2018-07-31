//
//  FileManager+Extension.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/27.
//  Copyright © 2018年 com.chq. All rights reserved.
//

import Foundation

extension FileManager {
    
    private static let manager = FileManager.default
    
    class var document: String {
        get {
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        }
    }
    
    class func isExist(at path: String) -> Bool {
        if manager.fileExists(atPath: path) {
            return true
        } else {
            return false
        }
    }
    
    class func save(_ data: Data, savePath: String) -> Error? {
        if manager.fileExists(atPath: savePath) {
            do {
                try manager.removeItem(atPath: savePath)
            } catch let error  {
                return error
            }
        }
        do {
            try data.write(to: URL(fileURLWithPath: savePath))
        } catch let error {
            return error
        }
        return nil
    }
    
    
}
