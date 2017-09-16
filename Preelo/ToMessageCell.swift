//
//  ToMessageCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class ToMessageCell: UITableViewCell {

    @IBOutlet fileprivate(set) weak var cardView         : UIView!
    @IBOutlet fileprivate weak var nameLabel        : UILabel!
    @IBOutlet fileprivate(set) weak var descriptionLabel : UILabel!
    @IBOutlet fileprivate weak var timeStamp        : UILabel!
    
    static let cellId = "ToMessageCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardView.layer.cornerRadius = 8
        cardView.layer.borderColor = UIColor.colorWithHex(0xe6e7e8).cgColor
        cardView.layer.borderWidth = 0.8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func showMessage(_ message: RecentMessages, name: String) {
        
        descriptionLabel.text = message.message_text
        nameLabel.text = name
        timeStamp.text = Date.dateDiff(dateStr: message.message_date)
    }
    
    @objc fileprivate func copyItem() {
        
        UIPasteboard.general.string = self.descriptionLabel.text
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        return (action == #selector(copyItem))
    }
}
