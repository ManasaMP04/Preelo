//
//  DisclaimerVC.swift
//  Preelo
//
//  Created by Manasa MP on 14/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class DisclaimerVC: UIViewController {
    
    @IBOutlet fileprivate weak var customeNavigation    : CustomNavigationBar!
    @IBOutlet fileprivate weak var agreeButton          : UIButton!
    @IBOutlet fileprivate weak var dontAgreeButton      : UIButton!
    @IBOutlet fileprivate weak var descriptionLabel     : UITextView!
    
    fileprivate var activityIndicator                   : UIActivityIndicatorView?
    fileprivate var channelDetail                       : ChannelDetail!
    fileprivate var descriptionStr = " The messages shared and the images uploaded in this app may not be immediately available to the doctor for review. Please understand the doctors might be attending other patients and this messages could possibly read at later time (24-48 hours), if this is an important message and need urgent response, send the message and call the doctor to inform about the message. This app is mainly focussed on delivering the images so that the doctor can review and provide initial feedback. This app is not intended for diagnosis or prescription. Please agree to the above terms to continue "
    
    init (_ channelDetail: ChannelDetail) {
        
        self.channelDetail = channelDetail
        super.init(nibName: "DisclaimerVC", bundle: nil)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func agreeButtonTapped(_ sender: Any) {
        
        callAPI()
    }
    
    @IBAction func iDontAgreeButtonTapped(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

//MARK:- Private methods

extension DisclaimerVC {
    
    fileprivate func setup () {
        
        customeNavigation.setTitle("DISCLAIMER")
        customeNavigation.delegate = self
        StaticContentFile.setButtonFont(agreeButton)
        StaticContentFile.setButtonFont(dontAgreeButton, backgroundColorNeeed: false, borderNeeded: false, shadowNeeded: false)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        let attributes = [NSParagraphStyleAttributeName : style, NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.colorWithHex(0x939598)]
        descriptionLabel.attributedText = NSAttributedString(string: descriptionStr, attributes:attributes)
        descriptionLabel.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    fileprivate func callAPI() {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(AuthorizeRouter.post(channelDetail))
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.activityIndicator?.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    let alertVC = AlertVC("DISCLAIMER", description: self.attributeText(withText: self.channelDetail.doctorname), notificationTitle: "Notification", navigation: self.parent)
                    alertVC.delegate = self
                    alertVC.providesPresentationContextTransitionStyle = true;
                    alertVC.definesPresentationContext = true;
                    alertVC.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
                    self.present(alertVC, animated: true, completion: nil)
                }}
    }
    
    fileprivate func attributeText(withText text: String) -> NSMutableAttributedString {
        
        let output      = NSMutableAttributedString(string: "Notification has been sent to")
        let opt = NSMutableAttributedString(string: " Doctor " + text)
        
        let attr = [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName:UIColor.colorWithHex(0x23B5B9)]
        
        opt.addAttributes(attr, range: NSMakeRange(0, opt.length))
        
        output.append(opt)
        output.append(NSMutableAttributedString(string: " for authorization!"))
        
        return output
    }
}

//MARK:- CustomNavigationBarDelegate

extension DisclaimerVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

//MARK:- AddPatientVCDelegate

extension DisclaimerVC: AlertVCDelegate {
    
    func tappedDoneButton(_ alertVC: AlertVC) {
        
        dismiss(animated: false, completion: nil)
        
        if let vc = navigationController?.viewControllerWithClass(ChatVC.self) as?  ChatVC {
            
            vc.hideAuthRequest()
            _ = navigationController?.popToViewController(vc, animated: true)
        }
    }
}
