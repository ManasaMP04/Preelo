//
//  LoginDetailVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import Alamofire

class LoginDetailVC: UIViewController {
    
    @IBOutlet fileprivate weak var userName         : FloatingTextField!
    @IBOutlet fileprivate weak var password         : FloatingTextField!
    @IBOutlet fileprivate weak var login            : UIButton!
    @IBOutlet fileprivate weak var profileImageView : UIImageView!
    @IBOutlet fileprivate weak var titleLabel       : UILabel!
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
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
        
        if let email = userName.text, let password = password.text,
            StaticContentFile.isValidEmail(email) , password.characters.count > 0 {
            
            isDoctorLogIn ? callLogiApi(email, password: password, urlRequest: LogInRouter.doc_post(email, password)) : callLogiApi(email, password: password, urlRequest: LogInRouter.post(email, password))
        } else if let email = userName.text, !StaticContentFile.isValidEmail(email) {
            
            view.showToast(message: "Email id is invalid")
        } else {
            
            view.showToast(message: "Please enter the required fields")
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
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        
        if isDoctorLogIn {
            
            titleLabel.text        = "Hello Doctor!"
            profileImageView.image = UIImage(named: "Doctor-with-shadow")
        } else {
            
            titleLabel.text        = "Hello Patient"
            profileImageView.image = UIImage(named: "Patient")
        }
    }
    
    fileprivate func alertMessage(_ title: String, message: String) {
        
        let alertView = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            
            alertView.dismiss(animated: true, completion: nil)
        })
        
        alertView.addAction(action)
        self.present(alertView, animated: true, completion: nil)
    }
    
    fileprivate func callLogiApi(_ email: String, password: String,  urlRequest: URLRequestConvertible){
        
        activityIndicator?.startAnimating()
        
        Alamofire.request(urlRequest)
            .responseObject { (response: DataResponse<logIn>) in
                
                self.activityIndicator?.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS",
                    let loginDetail = result.loginDetail {
                    
                    let defaults = UserDefaults.standard
                    defaults.set(result.token, forKey: "token")
                    self.isDoctorLogIn ? defaults.set(loginDetail.doctorid, forKey: "id") : defaults.set(loginDetail.id, forKey: "id")
                    defaults.set(loginDetail.firstname, forKey: "name")
                    defaults.set(self.isDoctorLogIn, forKey: "isDoctorLogIn")
                    self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                } else if let result = response.result.value, result.status == "VERIFY" {
                    
                    self.alertMessage("Verify", message: result.message)
                    
                } else {
                    
                    self.view.showToast(message: "Login failed")
                }
        }
    }
}

