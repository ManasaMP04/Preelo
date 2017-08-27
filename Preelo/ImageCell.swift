//
//  ImageCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet fileprivate weak var imageView : UIImageView!
    
    static let cellId = "ImageCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollview.minimumZoomScale = 1.0
        scrollview.maximumZoomScale = 6.0
        scrollview.delegate = self
    }
    
    func showImage(_ msg: RecentMessages, showFullImage: Bool) {
        
        if !showFullImage {
            
            scrollview.isUserInteractionEnabled = false
            imageView.isUserInteractionEnabled = false
            showImage(msg.thumb_Url, placeHolder: "Small-Image-Loader-With-Shadow")
        } else {
            
            scrollview.isUserInteractionEnabled = true
            imageView.isUserInteractionEnabled = true
            showImage(msg.image_url,placeHolder: "Big-Image-loading")
        }
    }
    
    func showImageWithName(_ imageName: UIImage) {
        
        imageView.image        = imageName
    }
    
    fileprivate func showImage(_ image: String, placeHolder: String) {
  
        if let imageUrl     = URL(string: image) {

           imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: placeHolder))
        }
    }
}

extension ImageCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}
