//
//  EmojiDecoder.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/17.
//  Copyright © 2018年 quan. All rights reserved.
//

import Foundation
import YYImage

class EmojiDecoder {
    
    let checkString = "\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
    
    var font: UIFont!
    var plaintext: String!
    var emojiTags: [String]?
    var result: NSMutableAttributedString?
    var emojiSize: CGFloat!
    var attributeString: NSMutableAttributedString?
    var imageDatas = [[String: Any]]()
    
    init() {}

    
    /// change plainText to emojiText
    ///
    /// - Returns: if or no contain emoji,  how many emojis, emoji attText
    func decode(with plainText: String, font: UIFont) -> (Bool, Int, NSMutableAttributedString) {
        
        guard !plainText.isEmpty else { return (false, 0, NSMutableAttributedString(string: "")) }
        self.font = font
        self.plaintext = plainText
        initProperty()
       let matches = executeMatch(for: plainText)
        guard !matches.isEmpty else { return (false, 0, NSMutableAttributedString(string: plainText)) }
        setImageDatas(with: matches)
        setResultStringUseReplace()
        return (true, matches.count, result!)
    }
    
    func emojiCount(for plainText: String) -> Int {
        guard !plainText.isEmpty else { return 0 }
        return executeMatch(for: plainText).count
    }
    
    private func initProperty() {
        emojiTags = EmojiHelper.getEmojiTag()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let dict = [NSAttributedStringKey.font: font!, NSAttributedStringKey.paragraphStyle: paragraphStyle]
        let maxSize = CGSize(width: 100, height: Int.max)
        emojiSize = "/".boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes:dict, context: nil).size.height
        attributeString = NSMutableAttributedString(string: plaintext, attributes: dict)
    }
    
    private func executeMatch(for text: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: checkString, options: .caseInsensitive) else { return [] }
        let totalRange = NSRange(location: 0, length: text.count)
        return regex.matches(in: text, options: [], range: totalRange)
    }
    
    private func setImageDatas(with matches: [NSTextCheckingResult]) {
        
        for match in matches.reversed() {
            var record = [String: Any]()
            let matchRange = match.range
            let localIndex = plaintext.index(plaintext.startIndex, offsetBy: matchRange.location)
            let endIndex = plaintext.index(localIndex, offsetBy: matchRange.length)
            var desc = plaintext[localIndex..<endIndex]
            
            desc.removeFirst()
            desc.removeLast()
            if desc.isEmpty { continue }
            record["range"] = matchRange
            record["desc"] = String(desc)
            imageDatas.append(record)
        }
    }

    
    private func setResultStringUseReplace() {
        result = attributeString
        for dict in imageDatas {
            if let range = dict["range"] as? NSRange,
                let desc = dict["desc"] as? String,
                let imageName = EmojiHelper.getDefaultEmojiImageName(with: desc),
                let image = EmojiHelper.getDefaultEmojiImage(with: imageName)  {
                let emojiAttachment = EmojiAttachment()
                emojiAttachment.imageName = imageName
                emojiAttachment.image = image
                emojiAttachment.bounds = CGRect(x: 0, y: -3, width: emojiSize, height: emojiSize)
                let attachText = NSAttributedString(attachment: emojiAttachment)
                result?.replaceCharacters(in: range, with: attachText)
            }
        }
    }
    
    
    
    
    
}
