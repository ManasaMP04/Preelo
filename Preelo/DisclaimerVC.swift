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
    
    fileprivate var activityIndicator                   : UIActivityIndicatorView?
    fileprivate var channelDetail                       : ChannelDetail!
    
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
        StaticContentFile.setButtonFont(dontAgreeButton)
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
                    self.navigationController?.pushViewController(alertVC, animated: true)
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
        
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
