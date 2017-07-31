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
            
            let fileManager = FileManager.default
            
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("preelo")
            var path = name.replacingOccurrences(of: "https://api.preelo.com/api/image/get?token=", with: "")
            path = path.replacingOccurrences(of: "/", with: "")
            let imagePath = paths.appendingFormat("/%@", path)
            
            if !fileManager.fileExists(atPath: paths) {
                
                try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
            }
            
            if !fileManager.fileExists(atPath: imagePath) {
                
                imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "Image Placeholder_Fill"), options:.refreshCached, completed: { (image, error, none, url) in
                    
                    if let img = self.imageView.image, let imageData = UIImageJPEGRepresentation(img, 1.0) {
                        
                        fileManager.createFile(atPath: imagePath as String, contents: imageData, attributes: nil)
                    }
                })
            } else  {
                
                imageView.image = UIImage(contentsOfFile: imagePath)
            }
        }
    }
}
