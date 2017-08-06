//
//  MyFollowingCollectionViewController.swift
//  DragNDropSample
//
//  Created by Anup Harbade on 7/4/17.
//  Copyright © 2017 Anup Harbade. All rights reserved.
//

import UIKit
import CoreGraphics

private let reuseIdentifier = "Cell"

class MyFollowingCollectionViewController: UIViewController {
    private let sectionInsets = UIEdgeInsets(top: 30.0, left: 15.0, bottom: 15.0, right: 15.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var unfollowButton: UIButton!
    
    var offset: CGFloat = 0.0
    
    private var itemsPerRow: CGFloat {
        get {
            return 4 // UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? 4 : 5
        }
    }
    
    var images: [UIImage]!
    var assetsToBeUnfollowed: [IndexPath]?
    
    @IBAction func didTapUnfollowButton(_ sender: Any) {
        if let indexPaths = assetsToBeUnfollowed {
            let sortedIndexpaths = indexPaths.sorted(by: { (leftIndexPath, rightIndexPath) -> Bool in
                return leftIndexPath.item < rightIndexPath.item
            })
            var removedItemCount = 0
            for indexPath in sortedIndexpaths {
                images.remove(at: indexPath.item - removedItemCount)
                removedItemCount += 1
            }
            
            assetsToBeUnfollowed = nil
            offset = 0
            // reload the table here
            collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: indexPaths)
            }, completion: nil)
            // hide the placeholder view
            placeholderView.isHidden = true
            
            for subview in self.placeholderView.subviews {
                if let imageView = subview as? UIImageView {
                    imageView.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupDropOnPlaceholderView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            
        }) {  (context) in
            self.collectionView?.reloadData()
        }
    }
    
    func setupSubviews() {
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        images = loadImages()
        self.collectionView.dragDelegate = self
        
        //set corner radius of the unfollow button
        unfollowButton.layer.cornerRadius = 3.0
        
        //hide unfollow placeholder initially,
        placeholderView.isHidden = true
    }
    
    func setupDropOnPlaceholderView() {
        let dropInteraction = UIDropInteraction(delegate: self)
        placeholderView.addInteraction(dropInteraction)
        placeholderView.isUserInteractionEnabled = true
    }
}

// MARK: UICollectionViewDragDelegate methods
extension MyFollowingCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        if assetsToBeUnfollowed == nil {
            assetsToBeUnfollowed = [IndexPath]()
        }
        return dragItem(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItem(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        
        if placeholderView.isHidden == true {
            performPlaceholderAnimation(false)
        }
    }
    
    func performPlaceholderAnimation(_ hide:Bool)  {
//        UIView.animate(withDuration: 2.0, animations: {
            self.placeholderView.isHidden = false
//        }, completion: nil)
    }
}


// MARK: UIDropInteractionDelegate methods
extension MyFollowingCollectionViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) && session.items.count >= 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let dropLocation = session.location(in: placeholderView)
        
        let operation: UIDropOperation
        
        if placeholderView.bounds.contains(dropLocation) {
            operation = .copy
        } else {
            operation = .cancel
        }
        
        return UIDropProposal(operation: operation)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { (imageItems) in
            let images = imageItems as! [UIImage]
            for image in images {
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 135, height: 180)
                let centerX = (self.placeholderView.center.x + self.offset) - (self.placeholderView.frame.origin.x)
                let centerY = (self.placeholderView.center.y + self.offset) - (self.placeholderView.frame.origin.y)
                let center = CGPoint(x:centerX, y:centerY)
                imageView.center = center
                
                self.placeholderView.addSubview(imageView)
                self.offset += 3.0
            }
        }
    }
}

// MARK: UICollectionViewDataSource methods
extension MyFollowingCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        prepareCellForReuse(cell)
        if let imageView = imageView(at: indexPath) {
            
            imageView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: cell.contentView.frame.size.width,
                                     height: cell.contentView.frame.size.height)
            
            cell.contentView.addSubview(imageView)
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout delegate methods
extension MyFollowingCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        // 3:4 ratio height
        let heightPerItem = widthPerItem * 4 / 3
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: Utility methods
extension MyFollowingCollectionViewController {
    
    fileprivate func dragItem(for indexPath: IndexPath) -> [UIDragItem] {
        if let assets = assetsToBeUnfollowed {
            if assets.contains(indexPath) == false {
                assetsToBeUnfollowed?.append(indexPath)
            }
        }
        
        let image = images[indexPath.item]
        let itemProvider = NSItemProvider(object: image)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = image
        
        return [dragItem]
    }
    
    fileprivate func loadImages() -> [UIImage] {
        let images = [#imageLiteral(resourceName: "av.jpg"),#imageLiteral(resourceName: "br.jpg"),#imageLiteral(resourceName: "tvu"),#imageLiteral(resourceName: "dofp.jpg"),#imageLiteral(resourceName: "ett.jpg"),#imageLiteral(resourceName: "fmn.jpg"),#imageLiteral(resourceName: "fs.jpg"),#imageLiteral(resourceName: "gw.jpg"),#imageLiteral(resourceName: "hnk.jpg"),#imageLiteral(resourceName: "ij.jpg"),#imageLiteral(resourceName: "jr.jpg"),#imageLiteral(resourceName: "life.jpg"),#imageLiteral(resourceName: "lrd.jpg"),#imageLiteral(resourceName: "mnik.jpg"),#imageLiteral(resourceName: "sal.jpg"),#imageLiteral(resourceName: "sh.jpg"),#imageLiteral(resourceName: "sl.jpg"),#imageLiteral(resourceName: "tdk.jpg"),#imageLiteral(resourceName: "th.jpg"),#imageLiteral(resourceName: "ti.png"),#imageLiteral(resourceName: "tlf.jpg"),#imageLiteral(resourceName: "tp.jpg"),#imageLiteral(resourceName: "tvu.jpg"),#imageLiteral(resourceName: "va.jpg"),#imageLiteral(resourceName: "vh.jpg")]
        return images
    }
    
    fileprivate func imageView(at indexPath:IndexPath) -> UIImageView? {
        
        guard images.count > indexPath.item else {
            return nil
        }
        
        let image = images[indexPath.item]
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 9999
        return imageView
    }
    
    fileprivate func prepareCellForReuse(_ cell:UICollectionViewCell) {
        let subViews = cell.contentView.subviews
        
        for view in subViews {
            if view.tag == 9999 {
                if let imageView = view as? UIImageView {
                    imageView.image = nil
                }
            }
        }
    }
}



