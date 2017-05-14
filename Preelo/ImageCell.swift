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

    func showImage(_ imageName: String) {
    
        let urlString         = imageName
        let imageUrl     = URL(string: urlString)
        imageView.sd_setImage(with: imageUrl, completed: nil)
    }
}
