//
//  ForgotPasswordVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet fileprivate weak var emailId              : FloatingTextField!
    @IBOutlet fileprivate weak var continueButton       : UIButton!
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        
        if let text = emailId.text, StaticContentFile.isValidEmail(text) {
            
            activityIndicator?.startAnimating()
            
            Alamofire.request(LogInRouter.forgotPassword(text))
                .responseObject { (response: DataResponse<ForgotPassword>) in
                    
                    self.activityIndicator?.stopAnimating()
                    
                    if let result = response.result.value, result.status == "SUCCESS" {
                        
                        UIView.animate(withDuration: 0.9, animations: {
                            
                            self.view.showToast(message: result.message)
                        }, completion: { (status) in
                            
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                        UIView.animate(withDuration: 0.5, animations: {
                            
                        })
                    }
                    else if let result = response.result.value {
                        
                        self.view.showToast(message: result.message)
                    }
            }
        } else {
            
            self.view.showToast(message: "Email id is invalid")
        }
    }
    
    fileprivate func setup() {
        
        emailId.setLeftViewIcon("UserName")
        StaticContentFile.setFontForTF(emailId, autoCaps: false)
        StaticContentFile.setButtonFont(continueButton)
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
    }
}
