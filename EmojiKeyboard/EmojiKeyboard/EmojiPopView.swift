//
//  EmojiPopView.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/21.
//  Copyright © 2018年 quan. All rights reserved.
//

import UIKit
import YYImage

let screenWidth = UIScreen.main.bounds.width

private let emojiSize = CGSize(width: 38, height: 38)
private let topPartSize = CGSize(width: emojiSize.width * 1.7, height: emojiSize.height * 1.7)
private let bottomPartSize = CGSize(width: emojiSize.width, height: emojiSize.height + 10)
private let emojiPopViewSize = CGSize(width: topPartSize.width, height: topPartSize.height + bottomPartSize.height)

private let imageEmojiSize = CGSize(width: 130, height: 130)
private let imageTopPartSize = CGSize(width: 150, height: 150)
private let imageBottomPartSize = CGSize(width: 20, height: 20)
private let imageEmojiPopViewSize = CGSize.init(width: imageTopPartSize.width, height: imageTopPartSize.height + imageBottomPartSize.height)

class EmojiPopView: UIView {
    
    var emojiType = EmojiType.default {
        didSet {
            isHidden = true
            var popViewSize = CGSize.zero
            if emojiType == .default {
                popViewSize = emojiPopViewSize
            } else {
                popViewSize = imageEmojiPopViewSize
            }
            frame = CGRect(x: 0, y: 0, width: popViewSize.width, height: popViewSize.height)
        }
    }
    var imageViewSize: CGSize {
        return emojiType == .default ? emojiSize : imageEmojiSize
    }
    
    var topSize: CGSize {
        return emojiType == .default ? topPartSize : imageTopPartSize
    }
    
    var bottomSize: CGSize {
        return emojiType == .default ? bottomPartSize : imageBottomPartSize
    }
    
    // the x location in the main viewController
    var locationX: CGFloat = 0
    var emojisWidth: CGFloat = 0
    var emojisX: CGFloat = 0
    var contentView = UIView()
    var viewModel: EmojiViewModel?
    var currentLocationFrame = CGRect.zero
    
    var animatedImageView: YYAnimatedImageView?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: emojiPopViewSize.width, height: emojiPopViewSize.height))
        isHidden = true
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // 这个计算后面再看看
        // adjust location of emoji bar if it is off the screen
//        emojisWidth = topPartSize.width + emojiSize.width * CGFloat(emojis.count - 1)
        emojisWidth = topSize.width
        // the x adjustment within the popView to account for the shift in location
        emojisX = 0
//        if emojisWidth + locationX > screenWidth {
//            // 8 for padding to border
//            emojisX = -(emojisWidth + locationX - screenWidth + 8)
//        }
        // readjust in case someone is long-pressing right at the edge of the screen
        if emojisX + emojisWidth < (topSize.width * 0.5 - bottomSize.width * 0.5) + bottomSize.width {
            emojisX = emojisX + ((topSize.width * 0.5 - bottomSize.width * 0.5) + bottomSize.width) - (emojisX + emojisWidth)
        }
        
        let path = CGMutablePath()
        path.addRoundedRect(in: CGRect(x: emojisX, y: 0, width: emojisWidth, height: topSize.height), cornerWidth: 10, cornerHeight: 10)
        if viewModel?.type == .default {
            path.addRoundedRect(in: CGRect(x: topSize.width * 0.5 - bottomSize.width * 0.5, y: topSize.height - 10, width: bottomSize.width, height: bottomSize.height + 10), cornerWidth: 5, cornerHeight: 5)
        } else {
            let arrowMinX = frame.width * 0.5 - (frame.midX - currentLocationFrame.midX)
            path.move(to: CGPoint(x: arrowMinX - 10, y: topSize.height))
            path.addLine(to: CGPoint(x: arrowMinX, y: topSize.height + 10))
            path.addLine(to: CGPoint(x: arrowMinX + 10, y: topSize.height))
        }
        
        // border
        let borderLayer = CAShapeLayer()
        borderLayer.path = path
        borderLayer.strokeColor = UIColor(white: 0.8, alpha: 1).cgColor
        borderLayer.fillColor = UIColor.white.cgColor
        borderLayer.lineWidth = 1
        layer.addSublayer(borderLayer)
        
        // mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        
        // content layer
        let contentLayer = CALayer()
        contentLayer.frame = bounds
        contentLayer.backgroundColor = UIColor.white.cgColor
        contentLayer.mask = maskLayer
        
        layer.addSublayer(contentLayer)

//         crash
//        contentView.removeFromSuperview()
        
        animatedImageView?.stopAnimating()
        
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: topSize.width, height: topSize.height))

        
        if viewModel?.type == .default {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: (contentView.width - imageViewSize.width) * 0.5, y: 5, width: imageViewSize.width, height: imageViewSize.height)
            imageView.image = EmojiHelper.getDefaultEmojiImage(with: viewModel?.defaultEmojiImageName ?? "")
            contentView.addSubview(imageView)
            
            let label = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY, width: contentView.frame.width, height: 15))
            var text = viewModel?.desc ?? ""
            if let last = text.last, Int(String(last)) != nil {
                text.removeLast()
            }
            label.textColor = UIColor.textInkGrayColor
            label.text = text
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            contentView.addSubview(label)
        } else {

            let imageView = YYAnimatedImageView()
            animatedImageView = imageView
            imageView.frame = CGRect(x: 0, y: 0, width: imageViewSize.width, height: imageViewSize.height)
            imageView.center = contentView.center
            imageView.contentMode = .scaleAspectFit
            if let viewModel = viewModel {
                EmojiHelper.getEmojiImage(for: imageView, with: viewModel)
                contentView.addSubview(imageView)
            }

        }
        addSubview(contentView)
        isHidden = true

    }
    
    
    func move(location: CGPoint, animation: Bool = true) {
        locationX = location.x
        setupUI()
        
        UIView.animate(withDuration: animation ? 0.08 : 0, animations: { [weak self] in
            guard let `self` = self else { return }
            self.alpha = 1
            self.frame = CGRect(x: location.x, y: location.y, width: self.frame.width, height: self.frame.height)
        }) { [weak self] (_) in
            self?.isHidden = false
        }
    }
    
    func dismiss() {
        currentLocationFrame = CGRect.zero
        UIView.animate(withDuration: 0.08, animations: { [weak self] in
            self?.alpha = 0
        }) { (_) in
            self.isHidden = true
        }
    }
    
    func update(with viewModel: EmojiViewModel, locationViewFrame: CGRect,  animation: Bool = true) {

        guard locationViewFrame != currentLocationFrame else { return }
        currentLocationFrame = locationViewFrame
        self.viewModel = viewModel
        var emojiPopX: CGFloat = 0
        var emojiPopY: CGFloat = 0
        if viewModel.type == .default {
            emojiPopX = locationViewFrame.origin.x - ((topSize.width - bottomSize.width) * 0.5) + 7
            emojiPopY = locationViewFrame.origin.y - topSize.height - 6
        } else {
            emojiPopX = locationViewFrame.midX - topSize.width * 0.5
            if emojiPopX < 0 {
                emojiPopX = 0
            } else if emojiPopX + topSize.width > screenWidth {
                emojiPopX = screenWidth - topSize.width
            }
            
            emojiPopY = locationViewFrame.origin.y - topSize.height - 12
        }

        let emojiPopLocation = CGPoint(x: emojiPopX, y: emojiPopY)
        if viewModel.type == .image {
            self.frame = CGRect(x: emojiPopLocation.x, y: emojiPopLocation.y, width: self.frame.width, height: self.frame.height)
        }
        move(location: emojiPopLocation, animation: animation)
    }
    
    
}


















