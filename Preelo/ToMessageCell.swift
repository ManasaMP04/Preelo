//
//  ToMessageCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class ToMessageCell: UITableViewCell {

    @IBOutlet fileprivate weak var cardView         : UIView!
    @IBOutlet fileprivate weak var nameLabel        : UILabel!
    @IBOutlet fileprivate weak var descriptionLabel : UILabel!
    @IBOutlet fileprivate weak var timeStamp        : UILabel!
    
    static let cellId = "ToMessageCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardView.layer.cornerRadius = 5
        cardView.addShadowWithColor(UIColor.colorWithHex(0x7c7c7c) , offset: CGSize.zero, opacity: 0.4, radius: 4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
 
    func showMessage(_ message: RecentMessages, name: String) {
        
        descriptionLabel.text = message.message_text
        nameLabel.text = name
        timeStamp.text = Date.dateDiff(dateStr: message.message_date)
    }
}
