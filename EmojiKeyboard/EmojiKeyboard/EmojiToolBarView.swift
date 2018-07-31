//
//  EmojiToolBarView.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/13.
//  Copyright © 2018年 quan. All rights reserved.
//

import UIKit

protocol EmojiToolBarViewDelegate: AnyObject {
    func send(toolBar: EmojiToolBarView)
    func itemSelect(toolBar: EmojiToolBarView, with index: Int)
}

class EmojiToolBarView: UIView {
    
    var scrollView: UIScrollView!
    var sendButton: UIButton!
    let buttonTag = 1990
    let buttonWidth: CGFloat = 50
    let sendButtonWidth: CGFloat = 76
    var items = [UIButton]()
    
    weak var delegate: EmojiToolBarViewDelegate?
    
    init(frame: CGRect, images: [UIImage]) {
        super.init(frame: frame)
        self.initView(images: images)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView(images: [UIImage]) {

        backgroundColor = UIColor.backgroudColor
        
        let height = frame.height
        sendButton = UIButton(type: .custom)
        sendButton.frame = CGRect(x: frame.width - sendButtonWidth, y: 0, width: sendButtonWidth, height: height)
        sendButton.backgroundColor = UIColor.mainColor
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        sendButton.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
        addSubview(sendButton)
        
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width - sendButtonWidth, height: height))
        scrollView.backgroundColor = UIColor.backgroudColor
        scrollView.contentSize = CGSize(width: CGFloat(images.count) * buttonWidth, height: 0)
        addSubview(scrollView)
        
        for (index,image) in images.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = buttonTag + index
            button.setImage(image, for: .normal)
            let buttonX = CGFloat(index) * buttonWidth
            button.frame = CGRect(x: buttonX, y: 0, width: buttonWidth, height: height)
            button.addTarget(self, action: #selector(itemSelectAction(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            items.append(button)
        }
        
        selectedItem(at: 0)
        
    }
    
    func selectedItem(at index: Int) {
        for (i, item) in items.enumerated() {
            if i == index {
                item.backgroundColor = UIColor.getRGBColor(230, 230, 230)
            } else {
                item.backgroundColor = UIColor.clear
            }
        }
    }
    
    func updateSendButtonStatus(_ status: Bool) {
        sendButton?.isEnabled = status
        if status {
            sendButton?.backgroundColor = UIColor.mainColor
            sendButton?.setTitleColor(UIColor.white, for: .normal)
        } else {
            sendButton?.backgroundColor = UIColor.backgroudColor
            sendButton?.setTitleColor(UIColor.textInkGrayColor, for: .normal)
        }
    }
    
    func isHideSendButton(_ isHide: Bool) {
        if isHide {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let `self` = self else { return }
                self.sendButton?.frame.origin.x = CGRect.windowsWidth
            }
            scrollView.width = CGRect.windowsWidth
        } else {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let `self` = self else { return }
                self.sendButton?.frame.origin.x = CGRect.windowsWidth - self.sendButtonWidth
            }
            scrollView.width = frame.width - sendButtonWidth
        }
    }
    
    
    @objc func sendAction(_ button: UIButton) {
        delegate?.send(toolBar: self)
    }
    
    @objc func itemSelectAction(_ button: UIButton) {
        let index = button.tag - buttonTag
        delegate?.itemSelect(toolBar: self, with: index)
        selectedItem(at: index)
    }
    
    
    
    
}
