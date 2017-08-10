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
        StaticContentFile.setButtonFont(acceptButton)
        
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
        initial.layer.cornerRadius = 20
        initial.clipsToBounds = true
        countLabel.layer.cornerRadius = 10
        countLabel.clipsToBounds = true
        initial.layer.borderWidth = 1
    }
    
    func showData(_ data: Any, isdeclineRequestViewShow: Bool = false) {
        
        initial.isHidden = true
        countLabel.isHidden = true
        
        if let auth = data as? DocAuthorizationRequest, StaticContentFile.isDoctorLogIn(){
            
            self.name.text = auth.firstname
            descriptionLabel.text = String(format: "Patient %@ %@ has sent You an authorization request", auth.firstname, auth.lastname)
            
            initial.isHidden = false
            parentName.text = ""
            
            if let  firstCh = auth.relationship.characters.first {
                
                let srt = "\(firstCh)"
                initial.text = srt.uppercased()
            }
        } else if let auth = data as? DocAuthorizationRequest, !StaticContentFile.isDoctorLogIn() {
            
            self.name.text = auth.doctor_firstname + " " + auth.doctor_lastname
            descriptionLabel.text = String(format: "You have been invited by the Doctor %@ %@ to authorize yourself for sending images and messages.", auth.doctor_firstname, auth.doctor_lastname)
            
            initial.isHidden = false
            parentName.text = ""
            
            initial.text = "D"
        } else if let channel = data as? ChannelDetail {
            
            if let message = channel.recent_message.last {
                
                descriptionLabel.text = message.message_text
            } else {
                
                descriptionLabel.text = ""
            }
            
            countLabel.isHidden = channel.unread_count == 0
            countLabel.text = "\(channel.unread_count)"
            name.textColor = channel.unread_count == 0 ? UIColor.colorWithHex(0x6D6E71) : UIColor.colorWithHex(0x3CCAE0)
            
            if StaticContentFile.isDoctorLogIn() {
                
                parentName.text = channel.parentname
                self.name.text = channel.patientname
                
                if let  firstCh = channel.relationship.characters.first {
                    
                    initial.isHidden = false
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
                
                if let  firstCh = channel.doctorname.characters.first {
                    
                    initial.isHidden = false
                    let srt = "\(firstCh)"
                    initial.text = srt.uppercased()
                    initial.layer.borderColor = UIColor.colorWithHex(0x3CCAE0).cgColor
                    initial.backgroundColor = UIColor.white
                }
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
