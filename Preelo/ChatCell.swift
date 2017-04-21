//
//  ChatCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var declineRequestView   : UIView!
    @IBOutlet fileprivate weak var imageview            : UIImageView!
    @IBOutlet fileprivate weak var name                 : UILabel!
    @IBOutlet fileprivate weak var descriptionLabel     : UILabel!
    @IBOutlet fileprivate weak var time                 : UILabel!
    
    static let cellId = "ChatCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func showData(_ name: String, discription: String, time: String, image: String, isdeclineRequestViewHide: Bool = true) {
        
        self.name.text = name
        descriptionLabel.text = discription
        self.time.text = time
        imageview.image = UIImage(named: image)
        declineRequestView.isHidden = isdeclineRequestViewHide
    }
}
