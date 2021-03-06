//
//  ParentDetailCell.swift
//  Preelo
//
//  Created by Manasa MP on 11/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

@objc protocol ParentDetailCellDelegate: class {
    
    func parentDetailCell(_ cell: ParentDetailCell)
    @objc optional func parentDetailCellTappedLocation(_ cell: ParentDetailCell)
}

class ParentDetailCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var parentName        : UILabel!
    @IBOutlet fileprivate weak var editButton        : UIButton!
    @IBOutlet fileprivate weak var imageViewWidth    : NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewTrailing : NSLayoutConstraint!
    @IBOutlet fileprivate weak var cardView          : UIView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var editButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var initial: UILabel!
    @IBOutlet weak var initialWidth: NSLayoutConstraint!
    @IBOutlet weak var editTrailing: NSLayoutConstraint!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var nameLabelLeading: NSLayoutConstraint!
    weak var delegate: ParentDetailCellDelegate?
    @IBOutlet weak var separatorTrailing: NSLayoutConstraint!
    @IBOutlet weak var separator: UIView!
    
    static let cellId = "ParentDetailCell"
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func showParentName(_ name: String, showImage: Bool, showEdit: Bool = true, image: String? = nil, showLocation: Bool = false, font: UIFont = UIFont(name: "Ubuntu", size: 14)!, color: UIColor = UIColor.colorWithHex(0x414042), showInitial: Bool = false, initialText: String = "", isLocationSelected: Bool = false, showSeparator: Bool = true, separatorLeadingSpace: CGFloat? = nil) {
        
        parentName.font = font
        parentName.textColor = color
        parentName.text = name
        
        initial.isHidden = !showInitial
        initialWidth.constant = showInitial ? 28 : 0
        imageViewWidth.constant = showImage ? 15 : 0
        imageView1.isHidden = !showImage
        initial.text = initialText
        
        if let const = separatorLeadingSpace {
            
            nameLabelLeading.constant = const
        } else {
            nameLabelLeading.constant = (showImage || showInitial) ? 15 : 37
        }
        editTrailing.constant = StaticContentFile.isDoctorLogIn() ? 30 : 10
        editButton.isHidden = !showEdit
        editButtonWidth.constant = showEdit ? 45 : 0
        separatorTrailing.constant = !StaticContentFile.isDoctorLogIn() ? 20 : 35
        separator.isHidden = !showSeparator
        
        if let img = image {
            
            editButton.setImage(UIImage(named: img), for: .normal)
            
        } else {
            
            editButton.setImage(nil, for: .normal)
            editButton.setTitle("EDIT", for: .normal)
        }
        
        let locImage = isLocationSelected ?  UIImage(named: "LocationDis") : UIImage(named: "Location")
        locationButton.setImage(locImage, for: .normal)
        locationButton.isHidden = !showLocation
        locationButtonWidth.constant = showLocation ? 45 : 0
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        delegate?.parentDetailCell(self)
    }
    
    @IBAction func tappedLocation(_ sender: Any) {
        
        delegate?.parentDetailCellTappedLocation?(self)
    }
}
