# EmojiKeyboard
Emoji keyboard, custom emoji, gif, preview.

[![Language: Swift 4](https://img.shields.io/badge/language-swift%204-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/cocoapods/p/YPImagePicker.svg?style=flat)](http://cocoapods.org/pods/YPImagePicker)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/liufengting/FTPopOverMenu_Swift/master/LICENSE)

[EmojiKeyboard](https://github.com/chquanquan/EmojiKeyboard) is a keyboard for `iOS` IM. contain emoji and GIF, preview function. manager emoji such as: add image or GIF from album. delete, drag to reorder.  Support plainText convert Emoji attributeText, emoji attributeText convert plainText.

sometimes you want to customer your style, add net sync function, change emoji sources. if you need some help, just send me Email: `380341629@qq.com`.

# ScreenShots

# Usage

* clone this repo.
* Simply drag and drop the 'EmojiKeyboard/EmojiKeyboard' folder into your project.
* change emoji demo resources, delete GIF demo resource

## simple code

create keyboard

```swift
   var emojiKeyboard: EmojiKeyboardView = {
       let keyboard = EmojiKeyboardView()
        keyboard.delegate = self
        return keyboard
    }()
    
    // set inputView
    textView.inputView = emojiKeyboard
```

Implementation protocol

```swift
extension ViewController: EmojiKeyboardViewDelegate {
    
    // click emoji
    func KeyboardView(_ KeyboardView: EmojiKeyboardView, use emoji: EmojiViewModel) {
        if emoji.type == .default {
            EmojiHelper.insertEmoji(for: textView, defaultEmojiImageName: emoji.defaultEmojiImageName!, desc: emoji.desc!)
        } else {
            EmojiHelper.getEmojiImage(for: imageView, with: emoji)
        }
    }
    
    // backward
    func emojiKeyBoardViewDidPressBackSpace(_ keyboardView: EmojiKeyboardView) {
        textView.deleteBackward()
    }
    
    // send action
    func sendContent(_ keyboardView: EmojiKeyboardView) {
        sendEmojiText()
    }
    
}

```
 ## advice
 
 you need add info Description
 * Privacy - Photo Library Additions Usage Description
 * Privacy - Photo Library Usage Description
 
 request authorization before access album. (emojiKeyboard already do.)
 
 first use EmojiKeyboard it will take some time load image Resouces from bundle, so I think you should preload the default   emoji sources to  menory.

# License

`EmojiKeyboard` is available under the `MIT` license. See the `LICENSE` file for more info.


