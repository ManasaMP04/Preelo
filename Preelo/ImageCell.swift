//
//  ImageCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol ImageCellDelegate: class {
    
    func imageCell(_ cell: ImageCell, enabled: Bool)
}

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet fileprivate weak var imageView : UIImageView!
    
    static let cellId = "ImageCell"
    weak var delegate: ImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollview.minimumZoomScale = 1.0
        scrollview.maximumZoomScale = 6.0
        scrollview.delegate = self
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    func showImage(_ msg: RecentMessages, showFullImage: Bool, mirror: Bool = false) {
        
        if mirror {
        
            contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        if !showFullImage {
            
            scrollview.isUserInteractionEnabled = false
            imageView.isUserInteractionEnabled = false
            
            showImage(getImageURLString(msg.thumb_Url), placeHolder: "Small-Image-Loader-With-Shadow")
        } else {
            
            scrollview.isUserInteractionEnabled = true
            imageView.isUserInteractionEnabled = true
            showImage(getImageURLString(msg.image_url),placeHolder: "Big-Image-loading", showToast: true)
        }
    }
    
    fileprivate func getImageURLString(_ imageURLString: String) -> String {
        
        var imageURl = ""
        for (i,s1) in imageURLString.components(separatedBy: "&key=").enumerated() {
            
            var str = s1
            if i == 0,
                let tokenRange = s1.range(of: "?") {
                
                str.removeSubrange(tokenRange.lowerBound..<str.endIndex)
                
                str.append("?token=\(StaticContentFile.getToken())")
                imageURl.append(str)
            }else {
                
                imageURl.append("&key=\(s1)")
            }
        }
        
        return imageURl
    }
    
    func showImageWithName(_ imageName: UIImage) {
        
        imageView.image        = imageName
    }
    
    fileprivate func showImage(_ image: String, placeHolder: String, showToast: Bool = false) {
        
        
        //        imageCache.queryDiskCache(forKey: imageUrl.absoluteString, done: {(_ image: UIImage, _ cacheType: SDImageCacheType) -> Void in
        //            if image {
        //                self.imageView.image = image
        //            }
        //            else {
        //                self.imageView.sd_setImage(withURL: imageUrl, placeholderImage: UIImage(named: "placeholder")!, completed: {(_ image: UIImage, _ error: Error, _ cacheType: SDImageCacheType, _ imageURL: URL) -> Void in
        //                    SDImageCache.shared().store(image, forKey: urlForImageString().absoluteString)
        //                })
        //            }
        //        })
        
        if let imageUrl     = URL(string: image) {
            
            imageView.sd_setImage(with: imageUrl,placeholderImage: UIImage(named: placeHolder),options: [], completed: { (img, error, cacheType, url) in
                
                self.delegate?.imageCell(self, enabled: img != nil)
            })
        }
    }
}

extension ImageCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}
