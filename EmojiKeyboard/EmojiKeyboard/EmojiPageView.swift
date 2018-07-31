//
//  EmojiPageView.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/13.
//  Copyright © 2018年 quan. All rights reserved.
//

import UIKit


protocol EmojiPageViewDelegate: AnyObject {
    func pageView(_ pageView: EmojiPageView, use emoji: EmojiViewModel)
    func pageViewDidPressBackSpace(_ pageView: EmojiPageView)
    func pageViewDidPressManager(_ pageView: EmojiPageView)
}

class EmojiPageView: UIView {
    
    let buttonTag = 1700

    weak var delegate: EmojiPageViewDelegate?
    var buttonSize: CGSize
    var buttons: [UIButton]
    var models = [EmojiViewModel]()
    var rows: Int
    var columns: Int
    var backSpaceButtonImage: UIImage?
    var emojiCategoryType = EmojiCategoryType.default
    
    init(frame: CGRect, emojiCategoryType: EmojiCategoryType,  backSpaceButtonImage: UIImage?, buttonSize: CGSize, rows: Int, columns: Int) {
        self.emojiCategoryType = emojiCategoryType
        self.backSpaceButtonImage = backSpaceButtonImage
        self.buttonSize = buttonSize
        self.rows = rows
        self.columns = columns
        buttons = [UIButton]()
        super.init(frame: frame)
        backgroundColor = UIColor.white

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createButton(at index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.adjustsImageWhenHighlighted = false
        button.tag = buttonTag + index
        let row = Int(index / columns)
        let column = Int(index % columns)
        button.frame = CGRect(x: xMargin(in: column), y: yMargin(in: row), width: buttonSize.width, height: buttonSize.height)
        button.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
        addSubview(button)
        buttons.append(button)
        return button
    }
    
    func xMargin(in column: Int) -> CGFloat {
        let padding = (bounds.width - CGFloat(columns) * buttonSize.width) / CGFloat(columns)
        return padding * 0.5 + CGFloat(column) * (padding + buttonSize.width)
    }
    
    func yMargin(in row: Int) -> CGFloat {
        let padding = (bounds.height - CGFloat(rows) * buttonSize.height) / CGFloat(rows)
        return padding * 0.5 + CGFloat(row) * (padding + buttonSize.height)
    }
    
    func setButtonContents(_ models: [EmojiViewModel]) {
        
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons = []
        self.models = []
        self.models = models
        
        for (index,model) in models.enumerated() {
            let button = createButton(at: index)
            if model.type == .default {
                button.setImage(EmojiHelper.getDefaultEmojiImage(with: model.defaultEmojiImageName!), for: .normal)
            } else if model.type == .image {
                if model.buttonType == .function {
                    button.setImage(UIImage(named: "EmojiKeyboard.bundle/manager"), for: .normal)
                } else {
                    button.imageView?.contentMode = .scaleAspectFit
                    EmojiHelper.getEmojiImage(for: button, with: model)
                }
            }
        }
        
        if emojiCategoryType == .default {
            let backspaceIndex = rows * columns - 1
            let backspaceButton = createButton(at: backspaceIndex)
            backspaceButton.setImage(backSpaceButtonImage ?? #imageLiteral(resourceName: "toolbar_icon_emojis_backspace"), for: .normal)
        }
        
    }
    
    @objc func buttonTap(_ button: UIButton) {
        let index = button.tag - buttonTag
        switch emojiCategoryType {
        case .default:
            if index == rows * columns - 1 {
                delegate?.pageViewDidPressBackSpace(self)
            } else {
                delegate?.pageView(self, use: models[index])
            }
        case .favorite:
            let model = self.models[index]
            if model.buttonType == .function {
                delegate?.pageViewDidPressManager(self)
            } else {
                delegate?.pageView(self, use: model)
            }
        }
    }
    

}






