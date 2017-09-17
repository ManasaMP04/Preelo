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
    
    @IBOutlet fileprivate weak var userName             : FloatingTextField!
    @IBOutlet fileprivate weak var password             : FloatingTextField!
    @IBOutlet fileprivate weak var login                : UIButton!
    @IBOutlet fileprivate weak var profileImageView     : UIImageView!
    @IBOutlet fileprivate weak var titleLabel           : UILabel!
    @IBOutlet fileprivate weak var forgotPasswordButton : UIButton!
    @IBOutlet fileprivate weak var createAccount        : UIButton!
    @IBOutlet fileprivate weak var scrollView           : UIScrollView!
    
    fileprivate var activityIndicator   : UIActivityIndicatorView?
    fileprivate var loginDetail         : logIn!
    fileprivate let plistManager        = PlistManager()
    fileprivate let defaults            = UserDefaults.standard
    
    var isDoctorLogIn: Bool = false
    
    fileprivate var scrollViewBottomInset : CGFloat! {
        
        didSet {
            
            var currentInset                = self.scrollView.contentInset
            currentInset.bottom             = scrollViewBottomInset
            self.scrollView.contentInset    = currentInset
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        if let vcs = navigationController?.viewControllers, vcs.count > 1 {
        
            _ = navigationController?.popViewController(animated: true)
        } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navigation")
            
            appDelegate.window?.rootViewController = initialViewController
        }
    }
    
    @IBAction func gestureIsTapped(_ sender: Any) {
    
        view.endEditing(true)
    }
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
   
        let vc = CreateAccount(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- IBActions

extension LoginDetailVC {
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        if let email = userName.text, let password = password.text,
            StaticContentFile.isValidEmail(email) , password.characters.count > 0, Reachability.forInternetConnection().isReachable() {
            
            isDoctorLogIn ? callLogiApi(email, password: password, urlRequest: LogInRouter.doc_post(email, password)) : callLogiApi(email, password: password, urlRequest: LogInRouter.post(email, password))
        } else if !Reachability.forInternetConnection().isReachable() {
        
            self.view.showToast(message: "Please check the internet connection")
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
        
        if userName.isFirstResponder {
        
            password.becomeFirstResponder()
        } else {
        
           loginButtonTapped(textField)
        }
    }
}

//MARK:- Private methods

extension LoginDetailVC {
    
    fileprivate func setup() {
        
        if let image = UIImage(named: "Doctor-Login-Screen") {
            
            view.backgroundColor = UIColor.init(patternImage: image)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        userName.selectAll(self)
        password.selectAll(self)
        userName.copy(self)
        password.copy(self)
        userName.textFieldDelegate = self
        userName.validateForInputType(.email, andNotifyDelegate: self)
        password.textFieldDelegate = self
        password.validateForInputType(.generic, andNotifyDelegate: self)
        userName.setLeftViewIcon("UserName")
        password.setLeftViewIcon("Password")
        
        StaticContentFile.setFontForTF(password, autoCaps: false)
        StaticContentFile.setFontForTF(userName, autoCaps: false)
        StaticContentFile.setButtonFont(login)
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        
        if isDoctorLogIn {
            
            titleLabel.text        = "Hello Doctor!"
            profileImageView.image = UIImage(named: "Doctor-with-shadow")
        } else {
            
            titleLabel.text        = "Hello Patient"
            profileImageView.image = UIImage(named: "Patient logo")
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
        self.view.isUserInteractionEnabled = false
        Alamofire.request(urlRequest)
            .responseObject { (response: DataResponse<logIn>) in
                
                StaticContentFile.removeAllKeys()
                
                if let result = response.result.value, result.status == "SUCCESS",
                    let detail = result.loginDetail {
                    
                    self.loginDetail = result
                    
                    self.defaults.set(result.token, forKey: "token")
                    self.defaults.set(result.socketServers, forKey: "socketServers")
                    SocketIOManager.sharedInstance.establishConnection()
                    self.isDoctorLogIn ? self.defaults.set(detail.doctorid, forKey: "id") : self.defaults.set(detail.id, forKey: "id")
                    self.defaults.set(detail.firstname, forKey: "name")
                    self.defaults.set(self.isDoctorLogIn, forKey: "isDoctorLogIn")
                    
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: detail)
                    self.defaults.set(encodedData, forKey: "userProfile")
                    self.defaults.synchronize()
                    
                    StaticContentFile.createDB()
                    self.callChannelAPI()
                } else if let result = response.result.value, result.status == "VERIFY" {
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator?.stopAnimating()
                    self.alertMessage("Verify", message: result.message)
                    
                } else if let result = response.result.value {
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator?.stopAnimating()
                    self.view.showToast(message: result.message)
                } else {
                
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator?.stopAnimating()
                    self.view.showToast(message: "Login failed")
                }
        }
    }
    
    fileprivate func callChannelAPI() {
        
        Alamofire.request(AuthorizationRequestListRouter.channel_get())
            .responseObject {(response: DataResponse<ChannelObject>) in
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    for detail in result.data {
                    
                        StaticContentFile.insertRowIntoDB(channelDetail: detail, dbManager: DBManager.init(fileName: "chat.db"))
                    }
                    
                    StaticContentFile.isDoctorLogIn() ? self.callAPIToGetAuthRequest() : self.callAPIToGetPatientAuthRequest()
                } else {
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator?.stopAnimating()
                    self.view.showToast(message: "Please try again something went wrong")
                }}
    }
    
    fileprivate func callAPIToGetAuthRequest() {
        
        Alamofire.request(AuthorizationRequestListRouter.get())
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                     self.defaults.set(true, forKey: "isLoggedIn")
                     StaticContentFile.saveAuthRequest(result)
                    StaticContentFile.callApiToRegisterDevice()
                    self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                }else {
                    
                    self.view.showToast(message: "Please try again something went wrong")
                }}
    }
    
    fileprivate func callAPIToGetPatientAuthRequest() {
        Alamofire.request(AuthorizationRequestListRouter.get_patient_AuthRequest())
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                if let result = response.result.value {
                    
                    self.defaults.set(true, forKey: "isLoggedIn")
                    StaticContentFile.saveAuthRequest(result)
                    StaticContentFile.callApiToRegisterDevice()
                    self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                }else {
                    
                    self.view.showToast(message: "Please try again something went wrong")
                }}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginSuccess", let tab = segue.destination as? TabBarVC {
            
            tab.loginDetail = loginDetail
        }
    }
}

extension LoginDetailVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let v1 = touch.view, v1 is UIButton {
            
            return false
        }
        return true
    }
}


//MARK:- KeyBoard delegate methods

extension LoginDetailVC {
    
    @objc fileprivate func keyboardWasShown(_ notification: Notification) {
        
        if let info = (notification as NSNotification).userInfo {
            
            let dictionary = info as NSDictionary
            
            let kbSize = (dictionary.object(forKey: UIKeyboardFrameBeginUserInfoKey)! as AnyObject).cgRectValue.size
            
            self.scrollViewBottomInset = kbSize.height + 10
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        
        self.scrollViewBottomInset = 0
    }
}

