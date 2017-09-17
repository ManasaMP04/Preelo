//
//  CreateAccount.swift
//  Preelo
//
//  Created by Manasa MP on 27/08/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import DXPopover

struct CreateAccountDetails {
    
    var  accountType : String
    var fName : String
    var lName : String
    var drFName : String
    var drLName : String
    var cityName : String
    var ccName : String
    var phone : String
    var email : String
}

class CreateAccount: UIViewController {
    
    fileprivate var isForCreateAccount = true
    
    enum Selection: Int {
        
        case account = 0
        case countryCode
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var countrycode: UILabel!
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var account: UIButton!
    @IBOutlet weak var accountTypeTitle: UILabel!
    @IBOutlet weak var accountType: UILabel!
    @IBOutlet weak var firstName: FloatingTextField!
    @IBOutlet weak var lastName: FloatingTextField!
    @IBOutlet weak var phoneNumber: FloatingTextField!
    @IBOutlet weak var email: FloatingTextField!
    @IBOutlet weak var createAccount: UIButton!
    @IBOutlet weak var countryCodeButton: UIButton!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var ccView: UIView!
    @IBOutlet weak var cityTf: FloatingTextField!
    @IBOutlet weak var drLastName: FloatingTextField!
    @IBOutlet weak var drFirstName: FloatingTextField!
    
    @IBOutlet weak var drDetailView: NSLayoutConstraint!
    
    fileprivate let popAnimator   = DXPopover()
    fileprivate var selection: Selection = .account
    fileprivate var cityList: CityList!
    
    fileprivate var isPatient = false
    
    fileprivate var scrollViewBottomInset : CGFloat! {
        
        didSet {
            
            var currentInset                = self.scrollView.contentInset
            currentInset.bottom             = scrollViewBottomInset
            self.scrollView.contentInset    = currentInset
        }
    }
    
    init (_ isForCreateAccount: Bool) {
        
        self.isForCreateAccount = isForCreateAccount
        super.init(nibName: "CreateAccount", bundle: nil)
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
    
    @IBAction func CountryCodeTapped(_ sender: Any) {
        
//        selection = .countryCode
//        presentPIckerView(countryCodeButton, data: cityList.countryCode)
    }
    
    @IBAction func gestureTapped(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func chooseAccountType(_ sender: Any) {
        
        selection = .account
        presentPIckerView(accountView, data: cityList.accounts)
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        
        create()
    }
    
    fileprivate func create() {
    
        if Reachability.forInternetConnection().isReachable() {
            
            if let phone = phoneNumber.text, phone.characters.count == 10,
                let email = email.text,StaticContentFile.isValidEmail(email),
                let lastname = lastName.text, lastname.characters.count > 0,
                let firstName = firstName.text,  firstName.characters.count > 0,
                let city = cityTf.text, city.characters.count > 0,
                let accountType = accountType.text,
                let cc = countrycode.text {
                
                var drFname = ""
                var drLname = ""
                if accountType == "Patient", let drFN = drFirstName.text, let drLN = drLastName.text {
                    
                    drFname = drFN
                    drLname = drLN
                } else if accountType == "Patient" {
                    
                    self.view.showToast(message: "Please Enter the required fields")
                }
                
                let detail = CreateAccountDetails(accountType: accountType,fName: firstName, lName: lastname, drFName: drFname, drLName: drLname, cityName: city, ccName: cc, phone: phone, email: email)
                
                isForCreateAccount ?  callAPIToCreatAccount(CreateAccountRouter.createAccount(detail), isForPatient: accountType == "Patient") : callAPIToCreatAccount(CreateAccountRouter.invite(detail), isForPatient: accountType == "Patient")
            } else {
                
                self.view.showToast(message: "Please Enter the required fields")
            }
        } else if !Reachability.forInternetConnection().isReachable() {
            
            self.view.showToast(message: "Please check the internet connection")
        }
    }
}

extension CreateAccount: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let v1 = touch.view, v1 is UIButton {
            
            return false
        }
        return true
    }
}

//MARK:- private methods

extension CreateAccount {
    
    fileprivate func presentPIckerView(_ sender: UIView, data: [String]) {
        
        let rect = self.view.convert(sender.frame, from: sender.superview)
        let v1 = UIView.init(frame: rect)
        let relationView    = RelationPickerView(data)
        relationView.delegate = self
        popAnimator.show(at: v1, withContentView: relationView, in: self.view)
    }
    
    fileprivate func prepareCityList () {
        
        let urlpath     = Bundle.main.path(forResource: "cityList", ofType: ".json")
        let url         = NSURL.fileURL(withPath: urlpath!)
        
        Alamofire.request(url).responseObject { (response: DataResponse<CityList>) in
            
            if let cityInfo = response.result.value {
                
                self.cityList   = cityInfo
            }
        }
    }
    
    fileprivate func callAPIToCreatAccount(_ request: URLRequestConvertible, isForPatient: Bool) {
        
        let activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        Alamofire.request(request)
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.showViewWithSuccesValue(result.message, isForPatient: isForPatient)
                } else if let result = response.result.value {
                    
                    self.view.showToast(message: result.message)
                }
        }
    }

    fileprivate func showViewWithSuccesValue(_ msg: String, isForPatient: Bool) {
    
        let duration = isForCreateAccount ? 3 : 8
        
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            
            self.view.showToast(message: msg)
        }, completion: { (status) in
            
            if self.isForCreateAccount,
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginDetailVC") as? LoginDetailVC {
                
                let nav = UINavigationController.init(rootViewController: vc)
                nav.navigationBar.isHidden = true
                appDelegate.window?.rootViewController = nav
                
                vc.isDoctorLogIn = !isForPatient
            } else if !self.isForCreateAccount {
                
                _ = self.navigationController?.popViewController(animated: true)
            }})
    }

    fileprivate func setup() {
        
        prepareCityList()
        
        self.automaticallyAdjustsScrollViewInsets = false
        accountTypeTitle.text = isForCreateAccount ? "Choose Your Account Type" : "Choose Recipient"
        account.layer.cornerRadius  = 5
        account.layer.borderWidth   = 1
        account.layer.borderColor   =  UIColor(white: 201/255, alpha: 1).cgColor
        isForCreateAccount ? customNavigationBar.setTitle("Create New Account") : customNavigationBar.setTitle("Send Invite")
        customNavigationBar.delegate = self
        
        firstName.selectAll(self)
        lastName.selectAll(self)
        email.selectAll(self)
        phoneNumber.selectAll(self)
        
        firstName.copy(self)
        lastName.copy(self)
        email.copy(self)
        phoneNumber.copy(self)
        
        drFirstName.isCompleteBoarder = true
        drFirstName.textFieldDelegate = self
        drLastName.isCompleteBoarder = true
        drLastName.textFieldDelegate = self
        cityTf.isCompleteBoarder = true
        cityTf.textFieldDelegate = self
        firstName.isCompleteBoarder = true
        firstName.textFieldDelegate = self
        phoneNumber.isCompleteBoarder = true
        phoneNumber.textFieldDelegate = self
        lastName.textFieldDelegate = self
        email.textFieldDelegate = self
        lastName.isCompleteBoarder = true
        email.isCompleteBoarder = true
        
        StaticContentFile.setFontForTF(drFirstName)
        StaticContentFile.setFontForTF(drLastName)
        StaticContentFile.setFontForTF(cityTf)
        StaticContentFile.setFontForTF(firstName)
        StaticContentFile.setFontForTF(lastName)
        StaticContentFile.setFontForTF(phoneNumber)
        StaticContentFile.setFontForTF(email, autoCaps: false)
        StaticContentFile.setButtonFont(createAccount, shadowNeeded: false)
        
        drFirstName.validateForInputType(.generic, andNotifyDelegate: self)
        drLastName.validateForInputType(.generic, andNotifyDelegate: self)
        cityTf.validateForInputType(.generic, andNotifyDelegate: self)
        phoneNumber.validateForInputType(.mobile, andNotifyDelegate: self)
        firstName.validateForInputType(.generic, andNotifyDelegate: self)
        lastName.validateForInputType(.generic, andNotifyDelegate: self)
        email.validateForInputType(.email, andNotifyDelegate: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
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

//MARK:- TextFieldDelegate

extension CreateAccount : PreeloTextFieldDelegate {
    
    func textFieldReturned(_ textField: PreeloTextField) {
        
        if firstName.isFirstResponder {
            
            lastName.becomeFirstResponder()
        } else if lastName.isFirstResponder, isPatient {
            
            drFirstName.becomeFirstResponder()
            
        } else if drFirstName.isFirstResponder {
            
            drLastName.becomeFirstResponder()
        } else if lastName.isFirstResponder || drLastName.isFirstResponder  {
            
            cityTf.becomeFirstResponder()
        }else if cityTf.isFirstResponder {
            
            phoneNumber.becomeFirstResponder()
        } else if phoneNumber.isFirstResponder {
            
            email.becomeFirstResponder()
        } else {
        
            create()
            self.view.endEditing(true)
        }
    }
}

extension CreateAccount: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

extension CreateAccount: RelationPickerViewDelegate {
    
    func relationPickerView(_ view: RelationPickerView, text: String) {
        
        if selection == .account {
            
            accountType.text = text
            
            if text == "Patient" {
                
                isPatient = true
                drDetailView.constant = 120
            } else {
                
                isPatient = false
                drDetailView.constant = 0
            }
        }
        
        popAnimator.dismiss()
    }
}

