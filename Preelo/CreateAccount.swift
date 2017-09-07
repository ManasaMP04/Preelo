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

class CreateAccount: UIViewController {
    
    fileprivate var isForCreateAccount = true
    
    enum Selection: Int {
        
        case account = 0
        case country
        case state
        case city
        case countryCode
    }

    @IBOutlet weak var countrycode: UILabel!
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var account: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var accountTypeTitle: UILabel!
    @IBOutlet weak var accountType: UILabel!
    @IBOutlet weak var firstName: FloatingTextField!
    @IBOutlet weak var lastName: FloatingTextField!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var phoneNumber: FloatingTextField!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var email: FloatingTextField!
    @IBOutlet weak var createAccount: UIButton!
    @IBOutlet weak var countryCodeButton: UIButton!
    
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var ccView: UIView!
    
    
    
    fileprivate let popAnimator   = DXPopover()
    fileprivate var selection: Selection = .account
    fileprivate var cityList: CityList!
    

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
        
        selection = .countryCode
        presentPIckerView(countryCodeButton, data: cityList.countryCode)
    }
    
    @IBAction func gestureTapped(_ sender: Any) {
    
        self.view.endEditing(true)
    }
    
    @IBAction func stateTapped(_ sender: Any) {
        
        selection = .state
        presentPIckerView(stateView, data: cityList.state)
    }
    
    @IBAction func cityTapped(_ sender: Any) {
        
        selection = .city
        presentPIckerView(cityView, data: cityList.city)
    }
    
    @IBAction func countryTapped(_ sender: Any) {
        
        selection = .country
        presentPIckerView(countryView, data: cityList.country)
    }
    
    @IBAction func chooseAccountType(_ sender: Any) {
        
        selection = .account
        presentPIckerView(accountView, data: cityList.accounts)
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        
        callAPIToCreatAccount()
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
    
    fileprivate func callAPIToCreatAccount() {
        
        if let phone = phoneNumber.text, phone.characters.count == 10,
            let email = email.text,StaticContentFile.isValidEmail(email),
            let lastname = lastName.text, lastname.characters.count > 0,
            let firstName = firstName.text,  firstName.characters.count > 0 {
            
            let activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
            activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            Alamofire.request(PatientRouter.get())
                .responseObject { (response: DataResponse<ForgotPassword>) in
                    
                    activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    if let result = response.result.value, result.status == "SUCCESS" {
                        
                        UIView.animate(withDuration: 0.9, animations: {
                            
                            self.view.showToast(message: result.message)
                        }, completion: { (status) in
                            
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        
                        self.view.showToast(message: "Patient Add is failed")
                    }}} else {
            
            self.view.showToast(message: "Please enter the required fields")
        }
    }
    
    fileprivate func setup() {
        
        prepareCityList()
        
        self.automaticallyAdjustsScrollViewInsets = false
        accountTypeTitle.text = isForCreateAccount ? "Choose Recipient" : "Send Invite"
        account.layer.cornerRadius  = 5
        account.layer.borderWidth   = 1
        account.layer.borderColor   =  UIColor(white: 201/255, alpha: 1).cgColor
        cityButton.layer.cornerRadius  = 5
        cityButton.layer.borderWidth   = 1
        cityButton.layer.borderColor   =  UIColor(white: 201/255, alpha: 1).cgColor
        stateButton.layer.cornerRadius  = 5
        stateButton.layer.borderWidth   = 1
        stateButton.layer.borderColor   =  UIColor(white: 201/255, alpha: 1).cgColor
        countryButton.layer.cornerRadius  = 5
        countryButton.layer.borderWidth   = 1
        countryButton.layer.borderColor   = UIColor(white: 201/255, alpha: 1).cgColor
        
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
        
        firstName.isCompleteBoarder = true
        firstName.textFieldDelegate = self
        phoneNumber.isCompleteBoarder = true
        phoneNumber.textFieldDelegate = self
        lastName.textFieldDelegate = self
        email.textFieldDelegate = self
        lastName.isCompleteBoarder = true
        email.isCompleteBoarder = true
        
        StaticContentFile.setFontForTF(firstName)
        StaticContentFile.setFontForTF(lastName)
        StaticContentFile.setFontForTF(phoneNumber)
        StaticContentFile.setFontForTF(email, autoCaps: false)
        StaticContentFile.setButtonFont(createAccount)
        
        firstName.validateForInputType(.generic, andNotifyDelegate: self)
        lastName.validateForInputType(.generic, andNotifyDelegate: self)
        email.validateForInputType(.email, andNotifyDelegate: self)
    }
}

//MARK:- TextFieldDelegate

extension CreateAccount : PreeloTextFieldDelegate {
    
    func textFieldReturned(_ textField: PreeloTextField) {
        
        if firstName.isFirstResponder {
            
            lastName.becomeFirstResponder()
        } else if lastName.isFirstResponder {
            
            phoneNumber.becomeFirstResponder()
        } else if phoneNumber.isFirstResponder {
            
            email.becomeFirstResponder()
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
        } else if selection == .country {
            
            country.text = text
        } else if selection == .state {
            
            state.text = text
        }else if selection == .city {
            
            city.text = text
        }else if selection == .countryCode {
            
            countrycode.text = text
        }
        
        popAnimator.dismiss()
    }
}

