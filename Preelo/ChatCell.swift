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
    @IBOutlet fileprivate weak var initial              : UILabel!
    @IBOutlet fileprivate weak var name                 : UILabel!
    @IBOutlet fileprivate weak var descriptionLabel     : UILabel!
    @IBOutlet fileprivate weak var acceptAuthViewHeight : NSLayoutConstraint!
    @IBOutlet fileprivate weak var declineButton        : UIButton!
    @IBOutlet fileprivate weak var acceptButton         : UIButton!
    @IBOutlet fileprivate weak var countLabel           : UILabel!
    
    static let cellId = "ChatCell"
    
    weak var delegate : ChatCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       setup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    fileprivate func setup() {
    
        StaticContentFile.setButtonFont(declineButton, backgroundColorNeeed: false)
        StaticContentFile.setButtonFont(acceptButton)
        declineButton.layer.cornerRadius = 18
        acceptButton.layer.cornerRadius  = 18
        initial.layer.cornerRadius = 15
        countLabel.layer.cornerRadius = 10
        countLabel.clipsToBounds = true
        initial.layer.borderWidth = 1
        initial.layer.borderColor = UIColor.colorWithHex(0x3CCAE0).cgColor
    }
    
    func showData(_ data: Any, isdeclineRequestViewShow: Bool = false) {
        
        initial.isHidden = true
        countLabel.isHidden = true
        
        if let auth = data as? DocAuthorizationRequest {
        
            self.name.text = auth.firstname
            descriptionLabel.text = String(format: "Patient %@ %@ has sent You an authorization request", auth.firstname, auth.lastname)
            
            initial.isHidden = false
            
            if let  firstCh = auth.relationship.characters.first, StaticContentFile.isDoctorLogIn() {
                
                let srt = "\(firstCh)"
                initial.text = srt.uppercased()
            } else if !StaticContentFile.isDoctorLogIn() {
                
                initial.text = "D"
            }
        } else if let channel = data as? ChannelDetail {
        
            self.name.text = channel.patientname
            
            if let message = channel.recent_message.last {
            
                descriptionLabel.text = message.message_text
            } else {
            
                 descriptionLabel.text = ""
            }
            
            initial.isHidden = false
            countLabel.isHidden = channel.unread_count == 0
            countLabel.text = "\(channel.unread_count)"
            name.textColor = channel.unread_count == 0 ? UIColor.colorWithHex(0x6D6E71) : UIColor.colorWithHex(0x3CCAE0)
            
            if let  firstCh = channel.relationship.characters.first, StaticContentFile.isDoctorLogIn() {
            
                let srt = "\(firstCh)"
                initial.text = srt.uppercased()
            } else if !StaticContentFile.isDoctorLogIn() {
            
                 initial.text = "D"
            }
            
        }
        
        declineRequestView.isHidden = !isdeclineRequestViewShow
        
        if isdeclineRequestViewShow {
            
            acceptAuthViewHeight.constant = 35
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
