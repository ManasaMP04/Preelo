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
    @IBOutlet fileprivate weak var parentName           : UILabel!
    @IBOutlet fileprivate weak var titleLeading         : NSLayoutConstraint!
    @IBOutlet fileprivate weak var volumeImage          : UIImageView!
    
    
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
        
        StaticContentFile.setButtonFont(declineButton, backgroundColorNeeed: false, shadowNeeded: false)
        StaticContentFile.setButtonFont(acceptButton, shadowNeeded: false)
        
        if StaticContentFile.isDoctorLogIn() {
            
            declineButton.setTitle("DECLINE", for: .normal)
            acceptButton.setTitle("ACCEPT", for: .normal)
        } else {
            
            declineButton.setTitle("CANCEL", for: .normal)
            acceptButton.setTitle("PENDING", for: .normal)
            acceptButton.isUserInteractionEnabled = false
        }
        declineButton.layer.cornerRadius = 18
        acceptButton.layer.cornerRadius  = 18
        initial.layer.cornerRadius = 25
        initial.clipsToBounds = true
        countLabel.layer.cornerRadius = 10
        countLabel.clipsToBounds = true
        initial.layer.borderWidth = 1
    }
    
    fileprivate func showAuthRequestTitle(_ title: String) {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSParagraphStyleAttributeName : style, NSFontAttributeName : UIFont(name: "Ubuntu", size: 13)!, NSForegroundColorAttributeName: UIColor.colorWithHex(0x939598)]
        descriptionLabel.attributedText = NSAttributedString(string:title, attributes:attributes)
    }
    
    func showData(_ data: Any, isdeclineRequestViewShow: Bool = false) {
        
        if let auth = data as? DocAuthorizationRequest {
            
            titleLeading.constant = 60
            countLabel.isHidden = true
            initial.isHidden = true
            volumeImage.isHidden = false
            self.name.text = auth.title
            showAuthRequestTitle(auth.subtitle)
            
            parentName.text = ""
        }  else if let channel = data as? ChannelDetail {
            
            if channel.lastMsg.characters.count > 0 {
                
                descriptionLabel.text = channel.lastMsg
            } else if let msg = channel.recent_message.last {
                
                descriptionLabel.text = msg.message_text
            }
            
            titleLeading.constant = 100
            initial.isHidden = false
            volumeImage.isHidden = true
            countLabel.isHidden = channel.unread_count == 0
            countLabel.text = "\(channel.unread_count)"
            name.textColor = channel.unread_count == 0 ? UIColor.colorWithHex(0x6D6E71) : UIColor.colorWithHex(0x3CCAE0)
            
            if StaticContentFile.isDoctorLogIn() {
                
                parentName.text = channel.parentname
                self.name.text = channel.patientname
                
                if let  firstCh = channel.relationship.characters.first {
                    
                    initial.layer.borderColor = UIColor.clear.cgColor
                    let srt = "\(firstCh)"
                    initial.text = srt.uppercased()
                    initial.textColor = UIColor.white
                    
                    if srt.lowercased() == "m" {
                        
                        initial.backgroundColor = UIColor.colorWithHex(0xFF6699)
                    } else if srt.lowercased() == "f" {
                        
                        initial.backgroundColor = UIColor.colorWithHex(0x66A1FF)
                    } else if srt.lowercased() == "b" || srt.lowercased() == "s" {
                        
                        initial.backgroundColor = UIColor.colorWithHex(0xB1CC64)
                    } else if srt.lowercased() == "g" {
                        
                        initial.backgroundColor = UIColor.colorWithHex(0x16A085)
                    } else {
                        
                        initial.backgroundColor = UIColor.colorWithHex(0x7F8C8D)
                    }
                }
            } else if !StaticContentFile.isDoctorLogIn() {
                
                parentName.text = channel.patientname
                self.name.text = channel.doctorname
                initial.text = channel.doctor_initials.uppercased()
                initial.layer.borderColor = UIColor.colorWithHex(0x3CCAE0).cgColor
                initial.backgroundColor = UIColor.white
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
