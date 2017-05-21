//
//  ImageListCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol ImageListCellDelegate: class {
    
    func imageListCell(_ cell: ImageListCell, imageList: [UIImage], index: Int)
}

class ImageListCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var nameLabel        : UILabel!
    @IBOutlet fileprivate weak var cardView         : UIView!
    @IBOutlet fileprivate weak var collectionView   : UICollectionView!
    
    var imageList = [UIImage]()
    
    weak var delegate: ImageListCellDelegate?
    static let cellId = "ImageListCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup ()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    fileprivate func setup () {
        
        cardView.layer.cornerRadius = 5
        cardView.addShadowWithColor(UIColor.colorWithHex(0x7c7c7c) , offset: CGSize.zero, opacity: 0.5, radius: 4)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: ImageCell.cellId)
    }
    
    func showImages(_ recentMessage: RecentMessages) {
    
        imageList = recentMessage.image_url
        collectionView.reloadData()
    }
}

extension ImageListCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellId, for: indexPath) as! ImageCell
        
        cell.showImage(imageList[indexPath.row])

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.imageListCell(self, imageList: imageList, index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width/2, height: 100)
    }
}
