//
//  EmojiKeyboardView.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/13.
//  Copyright © 2018年 quan. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let updateEmojiImageNotificationName = Notification.Name("updateEmojiImageNotificationName")
}

protocol EmojiKeyboardViewDelegate: AnyObject {
    func KeyboardView(_ KeyboardView: EmojiKeyboardView, use emoji: EmojiViewModel)
    func emojiKeyBoardViewDidPressBackSpace(_ keyboardView: EmojiKeyboardView)
    func sendContent(_ keyboardView: EmojiKeyboardView)
}

enum EmojiCategoryType {
    case `default`, favorite
}

enum EmojiType {
    case `default`, image
}

class EmojiKeyboardView: UIView {
    
    let toolBarHeight: CGFloat = 37
    let EmojibuttonWidth: CGFloat = 50
    let EmojibuttonHeight: CGFloat = 50
    let GifButtonWidth: CGFloat = 70
    let GifButtonHeight: CGFloat = 70
    let pageContolHeight: CGFloat = 20

    var toolBar: EmojiToolBarView!
    var pageControl: UIPageControl!
    var emojiPagesScrollView: UIScrollView!
    var emojiPopView = EmojiPopView()
    var pageViews = [EmojiPageView]()

    var categories = [EmojiCategoryType]()
    var currentCategoryIndex = 0
    var currentEmojiType: EmojiType {
        return categories[currentCategoryIndex] == .default ? .default : .image
    }
    
    var isChangedEmoji = false

    var buttonWidth: CGFloat {
        var width:CGFloat = 0
        let type = categories[currentCategoryIndex]
        switch type {
        case .default: width = EmojibuttonWidth
        case .favorite: width = GifButtonWidth
        }
        return width
    }
    
    var buttonHeight: CGFloat {
        var height:CGFloat = 0
        let type = categories[currentCategoryIndex]
        switch type {
        case .default: height = EmojibuttonHeight
        case .favorite: height = GifButtonHeight
        }
        return height
    }
    
    weak var delegate: EmojiKeyboardViewDelegate?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: CGRect.windowsWidth, height: 216 + CGRect.bottomSafeHeight))
        initEmojiData()
        initView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(layoutSubviews), name: Notification.Name.updateEmojiImageNotificationName, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        backgroundColor = UIColor.white
        
        let images = categories.map { (type) -> UIImage in
            switch type {
            case .default: return UIImage(named: "EmojiKeyboard.bundle/emoji_category")!
            case .favorite: return UIImage(named: "EmojiKeyboard.bundle/favorite_category")!
            }
        }
        
        toolBar = EmojiToolBarView(frame: CGRect(x: 0, y: frame.height - toolBarHeight - CGRect.bottomSafeHeight, width: frame.width, height: toolBarHeight), images: images)
        toolBar.delegate = self
        addSubview(toolBar)
        
        pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.getRGBColor(220, 220, 220)
        pageControl.currentPageIndicatorTintColor = UIColor.getRGBColor(108, 114, 115)
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        pageControl.backgroundColor = UIColor.clear
        
        var pageControlSize = pageControl.size(forNumberOfPages: 1)
        pageControlSize = CGSize(width: pageControlSize.width, height: pageContolHeight)
        let frameSize = CGSize(width: bounds.width, height: bounds.height - toolBar.height - pageControlSize.height)
        let numberOfPage = self.numberOfPage(for: currentCategoryIndex, in: frameSize)
        pageControlSize = pageControl.size(forNumberOfPages: numberOfPage)
        pageControlSize = CGSize(width: pageControlSize.width, height: pageContolHeight)
        pageControl.frame = CGRect(x: bounds.width - pageControlSize.width * 0.5, y: bounds.height - toolBarHeight - pageControlSize.height - CGRect.bottomSafeHeight, width: pageControlSize.width, height: pageControlSize.height)
        
        pageControl.addTarget(self, action: #selector(pageControlTouched(_:)), for: .valueChanged)
        addSubview(pageControl)
        
        let scrollViewFrame = CGRect.init(x: 0, y: 0, width: bounds.width, height: bounds.height - toolBarHeight - pageControlSize.height - CGRect.bottomSafeHeight)
        emojiPagesScrollView = UIScrollView(frame: scrollViewFrame)
        emojiPagesScrollView.isPagingEnabled = true
        emojiPagesScrollView.showsVerticalScrollIndicator = false
        emojiPagesScrollView.showsHorizontalScrollIndicator = false
        emojiPagesScrollView.delegate = self
        addSubview(emojiPagesScrollView)
        
        addSubview(emojiPopView)
        
        let LPGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandle(_:)))
        addGestureRecognizer(LPGesture)

    }
    
    func initEmojiData() {
        categories = [.default, .favorite]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var pageControlSize = pageControl.size(forNumberOfPages: 1)
        pageControlSize = CGSize(width: pageControlSize.width, height: pageContolHeight)
        let numberOfPages = numberOfPage(for: currentCategoryIndex, in: CGSize(width: bounds.width, height: bounds.height - toolBarHeight - pageControlSize.height))
        let currentPage = pageControl.currentPage > numberOfPages ? numberOfPages : pageControl.currentPage
        pageControl.numberOfPages = numberOfPages
        pageControlSize = pageControl.size(forNumberOfPages: numberOfPages)
        pageControlSize = CGSize(width: pageControlSize.width, height: pageContolHeight)
        let pageControlFrame = CGRect(x: (bounds.width - pageControlSize.width) * 0.5, y: bounds.height - toolBarHeight - pageControlSize.height - CGRect.bottomSafeHeight, width: pageControlSize.width, height: pageControlSize.height)
        pageControl.frame = pageControlFrame
        
        emojiPagesScrollView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - toolBarHeight - pageControlSize.height - CGRect.bottomSafeHeight)

        emojiPagesScrollView.contentOffset = CGPoint(x: bounds.width * CGFloat(currentPage), y: 0)
        emojiPagesScrollView.contentSize = CGSize(width: emojiPagesScrollView.bounds.width * CGFloat(numberOfPages), height: emojiPagesScrollView.bounds.height)
        purgePageViews()
        setPage(currentPage)
        
    }
    
    func purgePageViews() {
        for page in pageViews {
            page.delegate = nil
            page.removeFromSuperview()
        }
        pageViews = []
    }
    
    func setPage(_ page: Int) {
        setPageView(in: emojiPagesScrollView, at: page - 1)
        setPageView(in: emojiPagesScrollView, at: page)
        setPageView(in: emojiPagesScrollView, at: page + 1)
    }
    
    func setPageView(in scrollView: UIScrollView, at index: Int) {
        guard requireToSetPagView(for: index) else { return }
        let pageView = userableEmojiPageView()
        let rows = numberOfRows(for: scrollView.bounds.size)
        let columns = numberOfColumns(for: scrollView.bounds.size)
        
        var startingIndex = 0
        var endingIndex = 0
        switch categories[currentCategoryIndex] {
        case .default:
            startingIndex = index * (rows * columns - 1)
            endingIndex = (index + 1) * (rows * columns - 1)
        case .favorite:
            startingIndex = index * (rows * columns)
            endingIndex = (index + 1) * (rows * columns)
        }

        let models = getEmojiViewModel(from: startingIndex, to: endingIndex)
        pageView.setButtonContents(models)
        pageView.frame = CGRect(x: CGFloat(index) * scrollView.bounds.width, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        
    }
    
    func getEmojiViewModel(from fromIndex: Int, to toIndex: Int) -> [EmojiViewModel] {
        switch categories[currentCategoryIndex] {
        case .default:
            let emojis = EmojiHelper.getDefaultEmojis()
            let end = emojis.count > toIndex ? toIndex : emojis.count
            return Array(emojis[fromIndex..<end]).map({ (model) -> EmojiViewModel in
                return EmojiViewModel(from: model)
            })
        case .favorite:
            let images = EmojiHelper.getEmojiImages()
            let imagesCount = images.count + 1
            let end = imagesCount > toIndex ? toIndex : imagesCount
            
            var viewModels = images.map { (model) -> EmojiViewModel in
                return EmojiViewModel(from: model, buttonType: .normal)
            }
            viewModels.insert(EmojiViewModel(from: nil, buttonType: .function), at: 0)
            return Array(viewModels[fromIndex..<end])
        }

    }

    
    func userableEmojiPageView() -> EmojiPageView {
        var pageView: EmojiPageView?
        
        for page in pageViews {
            let pageNumber = Int(page.x / emojiPagesScrollView.bounds.width)
            if abs(Int(pageNumber - pageControl.currentPage)) > 1, page.emojiCategoryType == categories[currentCategoryIndex] {
                pageView = page
            }
        }
        if pageView == nil {
            pageView = createEmojiPageView()
        }
        
        return pageView!
    }
    
    func createEmojiPageView() -> EmojiPageView {
        let rows = numberOfRows(for: emojiPagesScrollView.bounds.size)
        let columns = numberOfColumns(for: emojiPagesScrollView.bounds.size)
        let pageFrame = CGRect(x: 0, y: 0, width: emojiPagesScrollView.bounds.width, height: emojiPagesScrollView.bounds.height)
        let pageView = EmojiPageView(frame: pageFrame, emojiCategoryType: categories[currentCategoryIndex], backSpaceButtonImage: UIImage(named: "EmojiKeyboard.bundle/backspace"), buttonSize: CGSize(width: buttonWidth, height: buttonHeight), rows: rows, columns: columns)
        pageView.delegate = self
        pageViews.append(pageView)
        emojiPagesScrollView.addSubview(pageView)
        return pageView
    }
    
    func requireToSetPagView(for index: Int) -> Bool {
        if index < 0 || index >= pageControl.numberOfPages { return false }
        for page in pageViews {
            if Int(page.x / emojiPagesScrollView.bounds.width) == index {
                return false
            }
        }
        return true
    }

    func numberOfPage(for index: Int, in frameSize: CGSize) -> Int {
        var count = 0
        let type = categories[index]
        switch type {
        case .default:
            count = EmojiHelper.getEmojiCount()
        case .favorite:
            count = EmojiHelper.getGifCount() + 1 // first is function button
        }
        let rows = numberOfRows(for: frameSize)
        let colunms = numberOfColumns(for: frameSize)
        var numberOfEmojisOnAPage = 0
        switch categories[currentCategoryIndex] {
        case .default:
            numberOfEmojisOnAPage = rows * colunms - 1
        case .favorite:
            numberOfEmojisOnAPage = rows * colunms
        }

        return Int(ceil(Float(count) / Float(numberOfEmojisOnAPage)))
        
    }
    
    func updateSendButtonStatus(_ status: Bool) {
        toolBar.updateSendButtonStatus(status)
    }
    
    // TODO: add code
    func setRecentsEmoji(emoji: EmojiViewModel) {
        
    }
    
    @objc func pageControlTouched(_ pageControl: UIPageControl) {
        var sbounds = emojiPagesScrollView.bounds
        sbounds.origin.x = sbounds.width * CGFloat(pageControl.currentPage)
        sbounds.origin.y = 0
        emojiPagesScrollView.scrollRectToVisible(sbounds, animated: true)
    }
    
    @objc func longPressHandle(_ LPGesture: UILongPressGestureRecognizer) {
        let location = LPGesture.location(in: self)
        guard longPressLocationInScrollView(location) else {
            emojiPopView.dismiss()
            return
        }
        
        var locationIndex = 0
        var buttonFrameInSuperView = CGRect.zero
        
        let scollViewLocation = convert(location, to: emojiPagesScrollView)
        let pageView = pageViews.filter { $0.frame.contains(scollViewLocation) }.first
        if pageView == nil { emojiPopView.dismiss(); return }
        
        for (index, button) in pageView!.buttons.enumerated() {
            if button.frame.contains(location) {
                locationIndex = index
                buttonFrameInSuperView = convert(button.frame, to: self)
                break
            }
        }
        
        if buttonFrameInSuperView != CGRect.zero, locationIndex < pageView!.models.count {
            let viewModel = pageView!.models[locationIndex]
            if LPGesture.state != .ended {
                if viewModel.type == .image, viewModel.buttonType == .function {
                    emojiPopView.dismiss()
                } else {
                    emojiPopView.update(with: viewModel, locationViewFrame: buttonFrameInSuperView, animation: LPGesture.state != .began)
                }
            } else {
                emojiPopView.dismiss()
                if viewModel.type == .default {
                    delegate?.KeyboardView(self, use: viewModel)
                }
            }
        } else {
            emojiPopView.dismiss()
        }
        
    }
    
    func longPressLocationInScrollView(_ location: CGPoint) -> Bool {
        return emojiPagesScrollView.frame.contains(location)
    }
    
    
    // MARK: - data methods
    
    func numberOfColumns(for frameSize: CGSize) ->Int {
        return Int(floor(frameSize.width / buttonWidth))
    }
    
    func numberOfRows(for frameSize: CGSize) -> Int {
        return Int(floor(frameSize.height / buttonHeight))
    }
    
    
}



extension EmojiKeyboardView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let newPageNumber = floor((scrollView.contentOffset.x - pageWidth * 0.5) / pageWidth) + 1
        guard pageControl.currentPage != Int(newPageNumber) else { return }
        pageControl.currentPage = Int(newPageNumber)
        setPage(pageControl.currentPage)
    }
}


extension EmojiKeyboardView: EmojiPageViewDelegate {
    func pageView(_ pageView: EmojiPageView, use emoji: EmojiViewModel) {
        setRecentsEmoji(emoji: emoji)
        delegate?.KeyboardView(self, use: emoji)
    }
    
    func pageViewDidPressBackSpace(_ pageView: EmojiPageView) {
        delegate?.emojiKeyBoardViewDidPressBackSpace(self)
    }
    
    func pageViewDidPressManager(_ pageView: EmojiPageView) {
        let VC = UIApplication.shared.activityViewController()
        let managerVC = EmojiManagerViewController()
        let nav = UINavigationController(rootViewController: managerVC)
        VC.present(nav, animated: true, completion: nil)
    }
    
    
}

extension EmojiKeyboardView: EmojiToolBarViewDelegate {
    func send(toolBar: EmojiToolBarView) {
        delegate?.sendContent(self)
    }
    
    func itemSelect(toolBar: EmojiToolBarView, with index: Int) {
        guard currentCategoryIndex != index else { return }
        currentCategoryIndex = index
        toolBar.isHideSendButton(categories[index] != .default)
        pageControl.currentPage = 0
        setNeedsLayout()
        emojiPopView.emojiType = currentEmojiType
    }
    
    
}















