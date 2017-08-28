//
//  FromMessageCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class FromMessageCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var cardView             : UIView!
    @IBOutlet fileprivate(set) weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var timeStamp            : UILabel!
    
    static let cellId = "FromMessageCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        cardView.layer.cornerRadius = 8
        cardView.layer.borderColor = UIColor.colorWithHex(0xe6e7e8).cgColor
        cardView.layer.borderWidth = 0.8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
    func showMessage(_ message: RecentMessages) {
        
        let str = Date.dateDiff(dateStr: message.message_date)
        timeStamp.text = str
        descriptionLabel.text = message.message_text
    }
}
