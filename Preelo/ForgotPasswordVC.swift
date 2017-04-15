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
    
    fileprivate func callLogiApi(_ email: String){
        
        Alamofire.request(LogInRouter.forgotPassword(email))
            .responseObject { (response: DataResponse<ForgotPassword>) in
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    _ = self.navigationController?.popViewController(animated: true)
                }
                else {
                    
                    self.view.showToast(message: "Reset password is failed")
                }
        }
    }
    
    fileprivate func setup() {
    
        continueButton.layer.cornerRadius  = continueButton.frame.size.width / 11
        continueButton.titleLabel?.font    = StaticContentFile.buttonFont
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
    }
}
