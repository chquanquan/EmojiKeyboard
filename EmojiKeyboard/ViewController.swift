//
//  ViewController.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/26.
//  Copyright © 2018年 com.chq. All rights reserved.
//

import UIKit
import YYImage

class ViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: YYAnimatedImageView!
    @IBOutlet weak var textView: UITextView!
    
    lazy var emojiKeyboard: EmojiKeyboardView = {
       let keyboard = EmojiKeyboardView()
        keyboard.delegate = self
        return keyboard
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.becomeFirstResponder()
        
        // preload default emoji resource from bundle
        DispatchQueue.main.async {
            let imageView = UIImageView()
            for imageName in EmojiHelper.getDefalultEmojiNames() {
                imageView.image = EmojiHelper.getDefaultEmojiImage(with: imageName)
            }
        }
        
        
    }
    
    func sendEmojiText() {
        
        textLabel.attributedText = textView.attributedText

//         if you want to send some one by plain text
//        let plainText = EmojiHelper.getPlanText(attributedText: textView.attributedText)
//        let (_, _, attText) = EmojiDecoder().decode(with: plainText, font: textView.font!)
//        textLabel.attributedText = attText
        
        textView.text = ""
    }
    
    
    
    // action
    @IBAction func changeKeyboard(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        textView.resignFirstResponder()
        if sender.isSelected {
            textView.inputView = emojiKeyboard
        } else {
            textView.inputView = nil
        }
        textView.becomeFirstResponder()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        textView.text  = ""
        textLabel.text = ""
        imageView.image = #imageLiteral(resourceName: "emoji_placeholder")
    }
    

}




extension ViewController: EmojiKeyboardViewDelegate {
    
    func KeyboardView(_ KeyboardView: EmojiKeyboardView, use emoji: EmojiViewModel) {
        if emoji.type == .default {
            EmojiHelper.insertEmoji(for: textView, defaultEmojiImageName: emoji.defaultEmojiImageName!, desc: emoji.desc!)
        } else {
            EmojiHelper.getEmojiImage(for: imageView, with: emoji)
        }
    }
    
    func emojiKeyBoardViewDidPressBackSpace(_ keyboardView: EmojiKeyboardView) {
        textView.deleteBackward()
    }
    
    func sendContent(_ keyboardView: EmojiKeyboardView) {
        sendEmojiText()
    }
    
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendEmojiText()
            return false
        }
        return true
    }
}











