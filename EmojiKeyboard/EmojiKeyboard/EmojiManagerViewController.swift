//
//  EmojiManagerViewController.swift
//  EmojiKeyboard
//
//  Created by quan on 2018/7/18.
//  Copyright © 2018年 quan. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "EmojiCollectionViewCell"

class EmojiManagerViewController: UIViewController {
    
    let bottomBarHeight: CGFloat = 50
    
    var collectionView: UICollectionView!
    var bottomBar: UIView!
    var stickyButton: UIButton!
    var countLabel: UILabel!
    var deleteButton: UIButton!
    var willStickyViewModels = [EmojiImageViewModel]()
    var longPressGR: UILongPressGestureRecognizer!
    var movingCell: EmojiCollectionViewCell?
    var addCell: EmojiCollectionViewCell?
    
    var isManagering = false
    var isChangedEmojis = false {
        didSet {
            EmojiHelper.saveEmojiImages(viewModels)
        }
    }

    lazy var backNavigationItem: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "EmojiKeyboard.bundle/backspace"), for: .normal)
        button.setTitle("    ", for: .normal)
        button.contentHorizontalAlignment = .left
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var cancelNavigationItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction(_:)))
    }()
    
    lazy var doneNavigationItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
    }()
    
    lazy var manageNavigationItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Manage", style: .plain, target: self, action: #selector(manageEmoji(_:)))
        if viewModels.count == 1 {
            item.isEnabled = false
        }
        return item
    }()
    
    var viewModels: [EmojiImageViewModel] = {

        let models = EmojiHelper.getEmojiImages()
        var viewModels = models.map({ (model) -> EmojiImageViewModel in
            return EmojiImageViewModel(model: model, imageViewType: .normal)
        })
        viewModels.insert(EmojiImageViewModel(model: nil, imageViewType: .function), at: 0)
        return viewModels
    }()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Favorite emojis"
        view.backgroundColor = UIColor.backgroudColor
        
        initView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isChangedEmojis {
            NotificationCenter.default.post(name: Notification.Name.updateEmojiImageNotificationName, object: nil)
        }
    }
    
    func initView() {
        
        navigationItem.leftBarButtonItem = backNavigationItem
        navigationItem.rightBarButtonItem = manageNavigationItem
        initCollectionView()
        initBottomBar()
    }
    
    func initCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let itemWidth = view.bounds.width / 5
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        collectionView.addGestureRecognizer(longPressGR)

    }
    
    func initBottomBar() {
        
        bottomBar = UIView(frame: CGRect(x: 0, y: collectionView.bounds.height, width: view.bounds.width, height: bottomBarHeight))
        bottomBar.backgroundColor = UIColor.backgroudColor
        
        stickyButton = UIButton(type: .custom)
        stickyButton.setTitle("Sticky", for: .normal)
        stickyButton.setTitleColor(UIColor.textBlackColor, for: .normal)
        stickyButton.setTitleColor(UIColor.buttondDisableColor, for: .disabled)
        stickyButton.isEnabled = false
        stickyButton.addTarget(self, action: #selector(stickyAction(_:)), for: .touchUpInside)
        bottomBar.addSubview(stickyButton)

        stickyButton.translatesAutoresizingMaskIntoConstraints = false
        let stickyButtonTop = NSLayoutConstraint(item: stickyButton, attribute: .top, relatedBy: .equal, toItem: bottomBar, attribute: .top, multiplier: 1, constant: 0)
        let stickyButtonLeft = NSLayoutConstraint(item: stickyButton, attribute: .left, relatedBy: .equal, toItem: bottomBar, attribute: .left, multiplier: 1, constant: 0)
        let stickyButtonBottom = NSLayoutConstraint(item: stickyButton, attribute: .bottom, relatedBy: .equal, toItem: bottomBar, attribute: .bottom, multiplier: 1, constant: 0)
        let stickyButtonWidth = NSLayoutConstraint.init(item: stickyButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        
        bottomBar.addConstraint(stickyButtonTop)
        bottomBar.addConstraint(stickyButtonLeft)
        bottomBar.addConstraint(stickyButtonBottom)
        bottomBar.addConstraint(stickyButtonWidth)
        

        
        countLabel = UILabel()
        countLabel.text = "\(viewModels.count - 1) Emojis"
        countLabel.textColor = UIColor.lightGray
        countLabel.textAlignment = .center
        bottomBar.addSubview(countLabel)
        
        deleteButton = UIButton(type: .custom)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(UIColor.destructColor, for: .normal)
        deleteButton.setTitleColor(UIColor.destructColor.withAlphaComponent(0.5), for: .disabled)
        deleteButton.isEnabled = false
        deleteButton.addTarget(self, action: #selector(deleteEmoji(_:)), for: .touchUpInside)
        bottomBar.addSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        let deleteButtonTop = NSLayoutConstraint(item: deleteButton, attribute: .top, relatedBy: .equal, toItem: bottomBar, attribute: .top, multiplier: 1, constant: 0)
        let deleteButtonBottom = NSLayoutConstraint(item: deleteButton, attribute: .bottom, relatedBy: .equal, toItem: bottomBar, attribute: .bottom, multiplier: 1, constant: 0)
        let deleteButtonTrailing = NSLayoutConstraint(item: deleteButton, attribute: .trailing, relatedBy: .equal, toItem: bottomBar, attribute: .trailing, multiplier: 1, constant: 0)
        let deleteButtonWidth = NSLayoutConstraint(item: deleteButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)

        bottomBar.addConstraint(deleteButtonTop)
        bottomBar.addConstraint(deleteButtonBottom)
        bottomBar.addConstraint(deleteButtonTrailing)
        bottomBar.addConstraint(deleteButtonWidth)

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        let countLabelTop = NSLayoutConstraint(item: countLabel, attribute: .top, relatedBy: .equal, toItem: bottomBar, attribute: .top, multiplier: 1, constant: 0)
        let countLabelLeading = NSLayoutConstraint(item: countLabel, attribute: .leading, relatedBy: .equal, toItem: stickyButton, attribute: .trailing, multiplier: 1, constant: 0)
        let countLabelBottom = NSLayoutConstraint(item: countLabel, attribute: .bottom, relatedBy: .equal, toItem: bottomBar, attribute: .bottom, multiplier: 1, constant: 0)
        let countLabelTrailing = NSLayoutConstraint(item: countLabel, attribute: .trailing, relatedBy: .equal, toItem: deleteButton, attribute: .leading, multiplier: 1, constant: 0)

        
        bottomBar.addConstraint(countLabelTop)
        bottomBar.addConstraint(countLabelLeading)
        bottomBar.addConstraint(countLabelBottom)
        bottomBar.addConstraint(countLabelTrailing)
        
        
        view.addSubview(bottomBar)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateBottomBar() {
        let selectedModels = viewModels.filter { (model) -> Bool in
            return model.isSelected
        }
        
        let hasSelected = !selectedModels.isEmpty
        
        stickyButton.isEnabled = hasSelected
        deleteButton.isEnabled = hasSelected
        
        let title = ("Delete") + (hasSelected ? "(\(selectedModels.count))" : "" )
        deleteButton.setTitle(title, for: .normal)
        
        countLabel.text = "\(viewModels.count - 1) Emojis"
        
    }
    
    func isShowEdit(_ status: Bool) {
        reloadEmojiShowSelect(status)
        isShowBottomBar(status)
    }
    
    func reloadEmojiShowSelect(_ isShow: Bool) {
        isManagering = isShow
        viewModels =  viewModels.map({ (model) -> EmojiImageViewModel in
            var model = model
            if model.imageViewType == .normal {
                model.showSelect = isShow
                model.isSelected = false
            }
            return model
        })
        collectionView.reloadData()
    }
    
    func isShowBottomBar(_ status: Bool) {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let `self` = self else { return }
            
            let changeHeight = status ? -(self.bottomBarHeight + CGRect.bottomSafeHeight) : (self.bottomBarHeight + CGRect.bottomSafeHeight)
            
            self.collectionView.height += changeHeight
            self.bottomBar.y += changeHeight
        }) { (_) in
            
        }
        
    }
    
    //  upate rank
    func updateRankAndCollectionView() {
        for (index,model) in viewModels.enumerated() {
            if model.imageViewType == .normal {
                viewModels[index].rank = index - 1
            }
            collectionView.reloadData()
        }
    }
    
    // MARK: - action
    
    @objc func longPressAction(_ longPressGR: UILongPressGestureRecognizer) {
        switch longPressGR.state {
        case .began:
            if let selectedIndex = collectionView.indexPathForItem(at: longPressGR.location(in: collectionView)),
                let cell = collectionView.cellForItem(at: selectedIndex) as?  EmojiCollectionViewCell,
                selectedIndex.item != 0 {
                cell.movingBorder()
                collectionView.beginInteractiveMovementForItem(at: selectedIndex)
                movingCell = cell
            }
        case .changed:
            if let addCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? EmojiCollectionViewCell {
                self.addCell = addCell
                let addCellFrame = addCell.frame
                if addCellFrame.contains(longPressGR.location(in: collectionView)) {
                    addCell.warningBorder()
                } else {
                    addCell.normalBorder()
                    collectionView.updateInteractiveMovementTargetPosition(longPressGR.location(in: longPressGR.view))
                }
            }
        case .ended:
            collectionView.endInteractiveMovement()
            movingCell?.normalBorder()
            addCell?.normalBorder()
        default:
            collectionView.cancelInteractiveMovement()
            movingCell?.normalBorder()
            addCell?.normalBorder()
        }
    }
    
    @objc func stickyAction(_ button: UIButton) {
        
        let addModel = viewModels.removeFirst()
        viewModels = ([addModel] + willStickyViewModels + viewModels.filter({ (model) -> Bool in
            return !willStickyViewModels.contains(where: { (stickyModel) -> Bool in
                return model.id == stickyModel.id
            })
        })).map({ (model) -> EmojiImageViewModel in
            var model = model
            if model.imageViewType == .normal {
                model.isSelected = false
            }
            return model
        })
        
        
        updateRankAndCollectionView()
        willStickyViewModels = []
        updateBottomBar()
        self.isChangedEmojis = true
        
    }
    
    @objc func deleteEmoji(_ button: UIButton) {

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (_) in
            self?.deleteAction()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let controller = UIAlertController.init(title: nil, message: "Deleted GIFs can't be recovered.", preferredStyle: .actionSheet)
        controller.addAction(deleteAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
        
        
    }
    
    @objc func deleteAction() {
        self.viewModels = self.viewModels.filter({ (model) -> Bool in
            return !model.isSelected
        })
        updateRankAndCollectionView()
        updateBottomBar()
        willStickyViewModels = []
        
        if self.viewModels.count == 1 {
            self.isShowEdit(false)
            self.manageNavigationItem.isEnabled = false
            self.navigationItem.leftBarButtonItem = self.backNavigationItem
            self.navigationItem.rightBarButtonItem = self.manageNavigationItem
        }
        self.isChangedEmojis = true

    }
    
    @objc func doneAction(_ item: UIBarButtonItem) {
        navigationItem.leftBarButtonItem = backNavigationItem
        navigationItem.rightBarButtonItem = manageNavigationItem

//        let selectedModels = viewModels.filter({ (model) -> Bool in
//            return model.isSelected
//        })
//
//        viewModels = viewModels.filter({ (model) -> Bool in
//            return !model.isSelected
//        })
        
        isShowEdit(false)
    }
    
    @objc func cancelAction(_ item: UIBarButtonItem) {
        navigationItem.leftBarButtonItem = backNavigationItem
        navigationItem.rightBarButtonItem = manageNavigationItem
        isShowEdit(false)
    }
    
    @objc func backAction(_ button: UIButton) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func manageEmoji(_ item: UIBarButtonItem) {
        navigationItem.leftBarButtonItem = cancelNavigationItem
        navigationItem.rightBarButtonItem = doneNavigationItem
        isShowEdit(true)
    }


}

extension EmojiManagerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModels.swapAt(sourceIndexPath.item, destinationIndexPath.item)
        updateRankAndCollectionView()
        isChangedEmojis = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var model = viewModels[indexPath.item]
        if model.imageViewType == .function, !isManagering {

            showImagePickerViewController()
            return
        }
        
        guard isManagering else { return }
        if model.imageViewType == .normal {
            let cell = collectionView.cellForItem(at: indexPath) as! EmojiCollectionViewCell
            model.isSelected = !model.isSelected
            viewModels[indexPath.item] = model
            cell.reloadData(model)
            updateBottomBar()
            
            if model.isSelected {
                willStickyViewModels.append(model)
                cell.selectedImageViewAnimate()
            } else {
                if let index = willStickyViewModels.index(where: { (orderModel) -> Bool in
                    return orderModel.id == model.id
                }) {
                    willStickyViewModels.remove(at: index)
                }
            }
        }
    }
        
}

extension EmojiManagerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EmojiCollectionViewCell
        let model = viewModels[indexPath.item]
        cell.reloadData(model)
        return cell
    }
    

}

extension EmojiManagerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerViewController() {
        
        EmojiHelper.authorizeToAlbum { [weak self] (hasAuthorized) in
            if hasAuthorized {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = false
                imagePickerController.sourceType = .photoLibrary
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    self?.present(imagePickerController, animated: true, completion: nil)
                }
            } else {
                let cancelAction = UIAlertAction.init(title: "Cancel", style: .default, handler: nil)
                let controller = UIAlertController(title: nil, message: "Do not have permission to use the camera, change your system settings!", preferredStyle: .alert)
                controller.addAction(cancelAction)
                
                self?.present(controller, animated: true, completion: nil)
            }
        }
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        var asset: PHAsset?
        
        if #available(iOS 11, *) {
            asset = info[UIImagePickerControllerPHAsset] as? PHAsset
        } else {
            if let url = info[UIImagePickerControllerReferenceURL] as? URL {
                asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject
            } 
        }
        let emojiId = UUID.string
        if let asset = asset {
            let list = PHAssetResource.assetResources(for: asset)
            for (index, resource) in list.enumerated() {
                print("index: \(index), resource: \(resource)")
                let options = PHAssetResourceRequestOptions()
                let assetId = resource.assetLocalIdentifier
                
                // prevent other same image to add
//                guard !EmojiHelper.hasSameEmijiImage(withAssetId: assetId) else {
//                    print("Already added.")
//                    return
//                }
                
                if resource.uniformTypeIdentifier == "com.compuserve.gif" {
                    if let path = EmojiHelper.getEmoijImageLocalPath(for: emojiId) {
                        let url = URL(fileURLWithPath: path)
                        var data: Data?
                        PHAssetResourceManager.default().writeData(for: resource, toFile: url, options: options) { [weak self] (error) in
                            guard let `self` = self else { return }
                            if let oldError = error {
                                let nsError = oldError as NSError
                                print("获取gif data 失败. \(error?.localizedDescription ?? "")")
                                if nsError.code == -1 {
                                    data = try? Data(contentsOf: url)
                                } else {
                                   print(oldError.localizedDescription)
                                }
                            } else {
                                data = try? Data(contentsOf: url)
                            }
                            if data != nil {
                                self.saveEmoji(id: emojiId, assetId: assetId, path: path)
                            }
                            
                        }
                    }
                } else {
                    // Filter out video of live photo
                    if resource.type == .photo {
                        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(image, 0.85) {
                            if let path = EmojiHelper.getEmoijImageLocalPath(for: emojiId) {
                                if let error = FileManager.save(imageData, savePath: path) {
                                    print("save emoji image error: \(error.localizedDescription)")
                                } else {
                                    self.saveEmoji(id: emojiId, assetId: assetId, path: path)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            print("asset is nil")
        }

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveEmoji(id: String, assetId: String, path: String) {

        let viewModel = EmojiImageViewModel(id: id, assetId: assetId, rank: viewModels.count, path: path, imageViewType: .normal, category: "favorite")
        viewModels.append(viewModel)
        collectionView.reloadData()
        updateBottomBar()
        manageNavigationItem.isEnabled = true
        isChangedEmojis = true
    }
    
    
}










