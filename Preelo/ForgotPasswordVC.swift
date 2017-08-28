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
        
        if let text = emailId.text, StaticContentFile.isValidEmail(text), Reachability.forInternetConnection().isReachable() {
            
            activityIndicator?.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            Alamofire.request(LogInRouter.forgotPassword(text))
                .responseObject { (response: DataResponse<ForgotPassword>) in
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator?.stopAnimating()
                    
                    if let result = response.result.value, result.status == "SUCCESS" {
                        
                        UIView.animate(withDuration: 0.9, animations: {
                            
                            self.view.showToast(message: result.message)
                        }, completion: { (status) in
                            
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    }
                    else if let result = response.result.value {
                        
                        self.view.showToast(message: result.message)
                    }
            }
        } else if !Reachability.forInternetConnection().isReachable() {
            
            self.view.showToast(message: "Please check the internet connection")
        } else {
        
            self.view.showToast(message: "Email id is invalid")
        }
    }
    
    fileprivate func setup() {
        
        emailId.copy(self)
        emailId.selectAll(self)
        emailId.setLeftViewIcon("UserName")
        emailId.textFieldDelegate = self
        emailId.validateForInputType(.email, andNotifyDelegate: self)
        StaticContentFile.setFontForTF(emailId, autoCaps: false)
        StaticContentFile.setButtonFont(continueButton)
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
    }
}

//MARK:- TextFieldDelegate

extension ForgotPasswordVC : PreeloTextFieldDelegate {
    
    func textFieldReturned(_ textField: PreeloTextField) {
        
        continueButtonTapped(textField)
    }
}
