//
//  LoginDetailVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class LoginDetailVC: UIViewController {
    
    @IBOutlet fileprivate weak var userName         : FloatingTextField!
    @IBOutlet fileprivate weak var password         : FloatingTextField!
    @IBOutlet fileprivate weak var login            : UIButton!
    @IBOutlet fileprivate weak var profileImageView : UIImageView!
    @IBOutlet fileprivate weak var titleLabel       : UILabel!
    
    var isDoctorLogIn: Bool = false
    
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
}

//MARK:- IBActions

extension LoginDetailVC {
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "loginSuccess", sender: nil)
        
        if userName.isValid() && password.isValid() {
            
            performSegue(withIdentifier: "loginSuccess", sender: nil)
        }
    }
}

//MARK:- TextFieldDelegate

extension LoginDetailVC : PreeloTextFieldDelegate {
    
    func textFieldReturned(_ textField: PreeloTextField) {
        
        view.endEditing(true)
    }
}

//MARK:- Private methods

extension LoginDetailVC {
    
    fileprivate func setup() {
        
        userName.textFieldDelegate = self
        userName.validateForInputType(.generic, andNotifyDelegate: self)
        password.textFieldDelegate = self
        password.validateForInputType(.generic, andNotifyDelegate: self)
        userName.setLeftViewIcon("UserName")
        password.setLeftViewIcon("Password")
        
        login.layer.cornerRadius  = login.frame.size.width / 11
        login.titleLabel?.font    = StaticContentFile.buttonFont
        
        if isDoctorLogIn {
        
            titleLabel.text        = "Hello Doctor!"
            profileImageView.image = UIImage(named: "Doctor-with-shadow")
        } else {
        
            titleLabel.text        = "Hello Patient"
            profileImageView.image = UIImage(named: "Patient")
        }
    }
}

