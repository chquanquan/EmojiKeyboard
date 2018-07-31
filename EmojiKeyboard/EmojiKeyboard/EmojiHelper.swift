//
//  EmojiHelper.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/16.
//  Copyright © 2018年 quan. All rights reserved.
//

import Foundation
import Photos
import YYImage

// emoji
struct EmojiHelper {
    
    static func getDefaultEmojis() -> [EmojiModel] {
        var models = [EmojiModel]()
        if let path = Bundle.main.path(forResource: "EmojiKeyboard.bundle/com.sina.emoji", ofType: "plist"), let emojis = NSArray(contentsOfFile: path) as? [[String: String]] {
            for emoji in emojis {
                if let imageName = emoji["image"], let desc = emoji["desc"] {
                    let model = EmojiModel(type: .default, desc: desc, defaultEmojiImageName: imageName)
                    models.append(model)
                }
            }
        }
        return models
    }
    
    static func getDefaultEmojiImage(with imageName: String) -> UIImage? {
        return UIImage(named: "EmojiKeyboard.bundle/com.sina.emoji/\(imageName)")
    }
    
    static func getDefaultEmojiImageName(with desc: String) -> String? {
        let emojis = getDefaultEmojis()
        for emoji in emojis {
            if emoji.desc == desc {
                return emoji.defaultEmojiImageName
            }
        }
        return nil
    }
    
    static func getEmojiCount() -> Int {
        if let path = Bundle.main.path(forResource: "EmojiKeyboard.bundle/com.sina.emoji", ofType: "plist"), let emojis = NSArray(contentsOfFile: path) as? [[String: String]] {
            return emojis.count
        }
        return 0
    }
    
    static func getEmojiTag() -> [String] {
        if let path = Bundle.main.path(forResource: "EmojiKeyboard.bundle/com.sina.emoji", ofType: "plist"), let emojis = NSArray(contentsOfFile: path) as? [[String: String]] {
            return emojis.map({ (dict) -> String in
                return dict["image"]!
            })
        }
        return []
    }
    

    
    static func insertEmoji(for textView: UITextView, defaultEmojiImageName: String, desc: String, complete: (() -> ())? = nil) {
        let font = UIFont.systemFont(ofSize: 14)
        let emojiAttachment = EmojiAttachment()
        emojiAttachment.imageName = defaultEmojiImageName
        emojiAttachment.desc = desc
        emojiAttachment.image = getDefaultEmojiImage(with: defaultEmojiImageName)
        let emojiSize = height(for: font)
        emojiAttachment.bounds = CGRect(x: 0, y: -3, width: emojiSize, height: emojiSize)
        textView.textStorage.insert(NSAttributedString(attachment: emojiAttachment), at: textView.selectedRange.location)
        textView.selectedRange = NSRange(location: textView.selectedRange.location + 1, length: textView.selectedRange.length)
        let wholeRange = NSRange(location: 0, length: textView.textStorage.length)
        textView.textStorage.removeAttribute(NSAttributedStringKey.font, range: wholeRange)
        textView.textStorage.addAttributes([NSAttributedStringKey.font: font], range: wholeRange)
        textView.scrollRectToVisible(CGRect(x: 0, y: 0, width: textView.contentSize.width, height: textView.contentSize.height), animated: false)
        complete?()
    }

    static func height(for font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: 100, height: CGFloat.greatestFiniteMagnitude)
        return "/".boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes:[NSAttributedStringKey.font: font], context: nil).size.height
    }
    
    static func getPlanText(attributedText: NSAttributedString) -> String {
        var stringM = NSMutableString(string: attributedText.string)
        var base = 0
        attributedText.enumerateAttribute(NSAttributedStringKey.attachment, in: NSRange(location: 0, length: attributedText.length)) { (value, range, stop) in
            if let attactment = value as? EmojiAttachment {
                let newRange = NSRange(location: range.location + base, length: range.length)
                stringM =  NSMutableString(string: stringM.replacingCharacters(in: newRange, with: "[\(attactment.desc)]"))
                if !attactment.imageName.isEmpty {
                    base += attactment.desc.count + 1 // + 2 -1
                }
            }
        }
        return stringM as String
    }

    
}


// MARK: - gif
extension EmojiHelper {
    
    static let emojiImageFolderPath = "\(FileManager.document)/emojiImage"
    static let emojiImagePlistPath = emojiImageFolderPath + "/emojiImage.plist"
    
    static func saveEmojiImages(_ viewModels: [EmojiImageViewModel]) {
        let models = viewModels.compactMap { (model) -> EmojiImageModel? in
            guard model.imageViewType != .function else { return nil }
            return EmojiImageModel(id: model.id!, assetId: model.assetId, rank: model.rank!, path: model.path, category: model.category!)
            }.map { (model) -> [String: String] in
                var dict = [String: String]()
                dict["id"] = model.id
                dict["assetId"] = model.assetId
                dict["rank"] = "\(model.rank)"
                dict["category"] = model.category
                return dict
        }
        
        let success = NSArray(array: models, copyItems: true).write(toFile: emojiImagePlistPath, atomically: true)
        if success {
            print("emojiImage plist save success")
        } else {
            print("emojiImage plist save failure")
        }
    }
    
    static func getEmojiImages() ->  [EmojiImageModel] {
        var models = [EmojiImageModel]()
        var images = [[String: String]]()
        
        if FileManager.isExist(at: emojiImagePlistPath),
            let imageDicts = NSArray(contentsOfFile: emojiImagePlistPath) as? [[String: String]] {
            images = imageDicts
        } else {
            if let path = Bundle.main.path(forResource: "GIF", ofType: "plist"),
                FileManager.isExist(at: path),
                let imagesDicts = NSArray(contentsOfFile: path) as? [[String: String]] {
                images = imagesDicts.map({ (dict) -> [String: String] in
                    var newDict = dict
                    let newId = UUID.string
                    if let oldPath = Bundle.main.path(forResource: newDict["name"]!, ofType: nil),
                        let newPath = EmojiHelper.getEmoijImageLocalPath(for: newId) {
                        try? FileManager.default.copyItem(atPath: oldPath, toPath: newPath)
                        newDict["id"] = newId
                    }
                    return newDict
                })
            }
        }
        
        for image in images {
            let path = EmojiHelper.getEmoijImageLocalPath(for: image["id"]!)
            let model = EmojiImageModel(id: image["id"]!, assetId: image["assetId"], rank: Int(image["rank"]!)!, path: path, category: image["category"]!)
            models.append(model)
        }
        
        return models
    }
    
    static func getEmoijImageLocalPath(for id: String) -> String? {
        
        if !FileManager.default.fileExists(atPath: emojiImageFolderPath) {
            do {
                try FileManager.default.createDirectory(atPath: emojiImageFolderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        return emojiImageFolderPath + "/\(id)"
        
    }
    
    
    static func getEmojiImage(for imageView: UIImageView, with model: EmojiImageViewModel) {
        guard let path = model.path else {
            print("path parameter is nil")
            imageView.image = UIImage(named: "EmojiKeyboard.bundle/gif")
            return
        }
        if let image = UIImage(contentsOfFile: path) {
            imageView.image = image
        }

    }
    
    static func getEmojiImage(for imageView: YYAnimatedImageView, with model: EmojiViewModel) {
        guard let path = model.path else {
            print("path parameter is nil")
            imageView.image = UIImage(named: "EmojiKeyboard.bundle/gif")
            return
        }
        
        // add "file://" for error:  CFURLCopyResourcePropertyForKey failed because it was passed an URL which has no scheme The file “img_00.gif” couldn’t be opened.
        if let url = URL(string: "file://\(path)"),
            let data = try? Data(contentsOf: url) {
                let image = YYImage(data: data)
                imageView.image = image
        }
        
    }

    
    static func getEmojiImage(for button: UIButton, with model: EmojiViewModel) {
        guard let path = model.path else {
            print("path parameter is nil")
            button.setImage(UIImage(named: "EmojiKeyboard.bundle/gif"), for: .normal)
            return
        }
        if let image = UIImage(contentsOfFile: path) {
            button.setImage(image, for: .normal)
        }
    }
    
    static func getGifCount() -> Int {
        return getEmojiImages().count
    }
    
    static func hasSameEmijiImage(withAssetId assetId: String) -> Bool {
        let emojis = getEmojiImages()
        for emoji in emojis {
            if emoji.assetId == assetId {
                return true
            }
        }
        return false
    }
    
}

extension EmojiHelper {
    
    static func authorizeToAlbum(hasAuthorize: @escaping (Bool) -> ()) {
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    DispatchQueue.main.async {
                        hasAuthorize(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        hasAuthorize(false)
                    }
                }
            }
        } else {
            hasAuthorize(true)
        }
    }
    
    
    
}

















