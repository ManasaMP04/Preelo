//
//  ForgotPasswordVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet fileprivate weak var emailId              : FloatingTextField!
    @IBOutlet fileprivate weak var continueButton       : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.layer.cornerRadius  = continueButton.frame.size.width / 11
        continueButton.titleLabel?.font    = StaticContentFile.buttonFont
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}
