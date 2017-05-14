//
//  ChatCell.swift
//  Preelo
//
//  Created by Manasa MP on 14/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol ChatCellDelegate: class {
    
    func chatCell(_ cell: ChatCell, isAuthAccepted: Bool)
}

class ChatCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var declineRequestView   : UIView!
    @IBOutlet fileprivate weak var imageview            : UIImageView!
    @IBOutlet fileprivate weak var name                 : UILabel!
    @IBOutlet fileprivate weak var descriptionLabel     : UILabel!
    @IBOutlet fileprivate weak var acceptAuthViewHeight : NSLayoutConstraint!
    
    static let cellId = "ChatCell"
    
    weak var delegate : ChatCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func showData(_ data: Any, isdeclineRequestViewShow: Bool = false) {
        
        if let auth = data as? DocAuthorizationRequest {
        
            self.name.text = auth.firstname
            descriptionLabel.text = String(format: "Patient %@ %@ has sent You an authorization request", auth.firstname, auth.lastname)
        } else if let channel = data as? ChannelDetail {
        
            self.name.text = channel.patientname
            
            if let message = channel.recent_message.last {
            
                descriptionLabel.text = message.message_text
            } else {
            
                 descriptionLabel.text = ""
            }
        }
        
        declineRequestView.isHidden = !isdeclineRequestViewShow
        
        if isdeclineRequestViewShow {
            
            acceptAuthViewHeight.constant = 45
        } else {
            
            acceptAuthViewHeight.constant = 0
        }
    }
    
    @IBAction func declineButtonIsTapped(_ sender: Any) {
    
        delegate?.chatCell(self, isAuthAccepted: false)
    }
    
    @IBAction func acceptButtonIsTapped(_ sender: Any) {
   
        delegate?.chatCell(self, isAuthAccepted: true)
    }
}
