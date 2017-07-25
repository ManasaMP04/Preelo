//
//  TermAndConditionVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 12/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class TermAndConditionVC: UIViewController {
    
    
    @IBOutlet weak fileprivate var customNavigation: CustomNavigationBar!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var feedback: UITextView!
    
    fileprivate let feedbackText = "The messages shared and the images uploaded in this app may not be immediately available to the doctor for review. Please understand the doctors might be attending other patients and this messages could possibly read at later time (24-48 hours), if this is an important message and need urgent response, send the message and call the doctor to inform about the message. This app is mainly focussed on delivering the images so that the doctor can review and provide initial feedback. This app is not intended for diagnosis or prescription. Please agree to the above terms to continue "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StaticContentFile.setButtonFont(goBackButton, backgroundColorNeeed: false, shadowNeeded: false)
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func goBackButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setup(){
        
        customNavigation.setTitle("Terms and Conditions")
        customNavigation.delegate = self
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        let attributes = [NSParagraphStyleAttributeName : style, NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.colorWithHex(0x939598)]
        feedback.attributedText = NSAttributedString(string: feedbackText, attributes:attributes)
        feedback.scrollRangeToVisible(NSRange(location:0, length:0))
    }
}

extension TermAndConditionVC:CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        
        self.navigationController?.popViewController(animated: true)
    }
}








