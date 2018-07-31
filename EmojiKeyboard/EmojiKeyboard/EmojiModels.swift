//
//  EmojiModel.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/17.
//  Copyright © 2018年 quan. All rights reserved.
//

import Foundation

struct EmojiViewModel {
    
    enum ButtonType {
        case function, normal
    }
    
    var buttonType: ButtonType = .normal
    let type: EmojiType
    var desc: String?
    var defaultEmojiImageName: String?
    var id: String?
    var path: String?
    
    init(from emojiModel: EmojiModel) {
        type = .default
        desc = emojiModel.desc
        defaultEmojiImageName = emojiModel.defaultEmojiImageName
    }
    
    init(from emojiImageModel: EmojiImageModel?, buttonType: ButtonType = .normal) {
        self.buttonType = buttonType
        type = .image
        id = emojiImageModel?.id
        path = emojiImageModel?.path
    }
}

struct EmojiModel {
    let type: EmojiType
    let desc: String
    let defaultEmojiImageName: String
}

struct EmojiImageModel {
    
    let id: String
    let assetId: String?
    var rank: Int
    var path: String?
    let category: String
    
}

// manager image Emoji
struct EmojiImageViewModel {
    
    enum EmojiImageViewType {
        case function, normal
    }
    
    let imageViewType: EmojiImageViewType
    let id: String?
    let assetId: String?
    var rank: Int?
    var path: String?
    var showSelect = false
    var isSelected = false
    let category: String?
    
    init(model: EmojiImageModel?, imageViewType: EmojiImageViewType) {
        self.imageViewType = imageViewType
        id = model?.id
        assetId = model?.assetId
        rank = model?.rank
        path = model?.path
        category = model?.category
    }
    
    init(id: String, assetId: String, rank: Int, path: String, imageViewType: EmojiImageViewType, category: String) {
        self.imageViewType = imageViewType
        self.id = id
        self.assetId = assetId
        self.rank = rank
        self.path = path
        self.category = category
    }
    
}













