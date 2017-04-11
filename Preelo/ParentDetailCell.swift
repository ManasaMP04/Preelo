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

    @IBOutlet fileprivate weak var parentName   : UILabel!
    @IBOutlet fileprivate weak var editButton   : UIButton!
    
    weak var delegate: ParentDetailCellDelegate?
    
    static let cellId = "ParentDetailCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         editButton.titleLabel?.font    = StaticContentFile.buttonFont
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func showParentName(_ name: String) {
    
        parentName.text = name
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
    
        delegate?.parentDetailCell(self)
    }
}
