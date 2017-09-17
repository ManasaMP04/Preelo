//
//  ImageListCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol ImageListCellDelegate: class {
    
    func imageListCell(_ cell: ImageListCell, imageList: [RecentMessages], index: Int)
}

class ImageListCell: UITableViewCell {
    
    @IBOutlet weak var toTime: UILabel!
    @IBOutlet weak var fromTime: UILabel!
    @IBOutlet fileprivate weak var toNameLabel        : UILabel!
    @IBOutlet fileprivate weak var collectionView   : UICollectionView!
    @IBOutlet fileprivate weak var fromNameLabel    : UILabel!
    
    var imageList = [RecentMessages]()
    var name      = ""
    
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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: ImageCell.cellId)
    }
    
    func showImages(_ recentMessage: RecentMessages, name: String) {
        
        self.name = name
        imageList = [recentMessage]
        collectionView.reloadData()
    }
}

extension ImageListCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellId, for: indexPath) as! ImageCell
        let msg = imageList[indexPath.row]
        let str = msg.senderId.lowercased()
        let time = Date.dateDiff(dateStr: msg.message_date)
        
        if str == "you" {
            
            fromNameLabel.text = "Me"
            toNameLabel.text = ""
            fromTime.text = time
            toTime.text = ""
            collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            
            fromNameLabel.text = ""
            toNameLabel.text = name
            fromTime.text = ""
            toTime.text = time
            collectionView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        cell.showImage(msg, showFullImage: false)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.imageListCell(self, imageList: imageList, index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width/2, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        cell.backgroundColor = UIColor.clear
    }
}
