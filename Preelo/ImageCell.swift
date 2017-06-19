//
//  ImageCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var imageView : UIImageView!
    
    static let cellId = "ImageCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func showImage(_ msg: RecentMessages, showFullImage: Bool) {
        
        if !showFullImage {
            
            showImage(msg.thumb_Url)
        } else {
        
            showImage(msg.image_url)
        }
    }
    
    func showImageWithName(_ imageName: UIImage) {
        
        imageView.image        = imageName
    }
    
    fileprivate func showImage(_ image: Any?) {
    
        if let name = image as? UIImage {
            
            imageView.image   = name
        } else if let name = image as? String {
            
            let imageUrl     = URL(string: name)
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "Image Placeholder_Fill"))
        }
    }
}
