//
//  ParentDetailCell.swift
//  Preelo
//
//  Created by Manasa MP on 11/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol ParentDetailCellDelegate: class {
    
    func parentDetailCell(_ cell: ParentDetailCell)
}

class ParentDetailCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var parentName        : UILabel!
    @IBOutlet fileprivate weak var editButton        : UIButton!
    @IBOutlet fileprivate weak var imageViewWidth    : NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewTrailing : NSLayoutConstraint!
    @IBOutlet fileprivate weak var cardView          : UIView!
    
    weak var delegate: ParentDetailCellDelegate?
    
    static let cellId = "ParentDetailCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func showParentName(_ name: String, showImage: Bool, showEdit: Bool = true, image: String? = nil) {
        
        parentName.text = name
        
        if !showImage {
            
            imageViewWidth.constant = 0
        } else {
            
            imageViewWidth.constant = 28
        }
        
        editButton.isHidden = !showEdit
        
        if let img = image {
         
            editButton.setImage(UIImage(named: img), for: .normal)
        } else {
        
            editButton.setTitle("Edit", for: .normal)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        editButton.setImage(UIImage(named: "minus"), for: .normal)
        delegate?.parentDetailCell(self)
    }
}
