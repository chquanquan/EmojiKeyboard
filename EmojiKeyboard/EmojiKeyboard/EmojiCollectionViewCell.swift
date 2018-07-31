//
//  EmojiCollectionViewCell.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/18.
//  Copyright © 2018年 quan. All rights reserved.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var selectedImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData(_ model: EmojiImageViewModel) {
        
        if model.imageViewType == .function {
            imageView.image = UIImage(named: "EmojiKeyboard.bundle/manager_add")
            selectedImageView.isHidden = true
        } else {
            EmojiHelper.getEmojiImage(for: imageView, with: model)
            selectedImageView.isHidden = !model.showSelect
            selectedImageView.image = model.isSelected ? UIImage(named: "EmojiKeyboard.bundle/selected") : UIImage(named: "EmojiKeyboard.bundle/unSelected")
        }
        
    }
    
    func initView() {

        normalBorder()
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView!)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewTop = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 10)
        let imageViewLeading = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10)
        let imageViewBottom = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -10)
        let imageViewTrailing = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10)
        contentView.addConstraint(imageViewTop)
        contentView.addConstraint(imageViewLeading)
        contentView.addConstraint(imageViewBottom)
        contentView.addConstraint(imageViewTrailing)
        

        selectedImageView = UIImageView()
        contentView.addSubview(selectedImageView)

        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        let selectedImageViewTop = NSLayoutConstraint(item: selectedImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        let selectedImageViewLeft = NSLayoutConstraint(item: selectedImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0)
        
        selectedImageView.frame.size = CGSize(width: 20, height: 20)
        
        contentView.addConstraint(selectedImageViewTop)
        contentView.addConstraint(selectedImageViewLeft)
        
    }
    
    func selectedImageViewAnimate() {
        selectedImageView.selectedVibrateAnimate()
    }
    
    func warningBorder() {
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.destructColor.cgColor
    }
    
    func normalBorder() {
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func movingBorder() {
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.mainColor.cgColor
    }

}






