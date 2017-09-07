//
//  AccountSettingsVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 12/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import Alamofire

fileprivate let cellHeight = CGFloat(45)

class AccountSettingsVC: UIViewController {
    
    enum Selection: Int {
        
        case personalInfo = 0
        case childrenListInfo
    }
    
    @IBOutlet fileprivate weak var saveButton: UIButton!
    @IBOutlet fileprivate weak var discardChangeButton: UIButton!
    @IBOutlet fileprivate weak var personalInfoButton: UIButton!
    @IBOutlet fileprivate  weak var childrenInfoButton: UIButton!
    @IBOutlet fileprivate weak var customNavigation: CustomNavigationBar!
    @IBOutlet fileprivate weak var firstName: FloatingTextField!
    @IBOutlet fileprivate weak var lastName: FloatingTextField!
    @IBOutlet fileprivate weak var emailAddress: FloatingTextField!
    @IBOutlet fileprivate weak var phoneNumber: FloatingTextField!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var password: FloatingTextField!
    @IBOutlet fileprivate weak var confirmPassword: FloatingTextField!
    
    fileprivate var selection: Selection = .childrenListInfo
    fileprivate var userProfile    : LogInDetail?
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
    fileprivate var scrollViewBottomInset : CGFloat! {
        
        didSet {
            
            var currentInset                = self.scrollView.contentInset
            currentInset.bottom             = scrollViewBottomInset
            self.scrollView.contentInset    = currentInset
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup ()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh() {
        
        userProfile = StaticContentFile.getUserProfile()
        tableView.reloadData()
    }
    
    @IBAction func gestureTapped(_ sender: Any) {
        
        self.view.endEditing(true)
    }
}

extension AccountSettingsVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let v1 = touch.view, v1 is UIButton {
            
            return false
        }
        return true
    }
}

extension AccountSettingsVC:CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK:- UITableViewDelegate, UITableViewDataSource

extension AccountSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userProfile?.children.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParentDetailCell.cellId, for: indexPath) as! ParentDetailCell
        cell.delegate = self
        
        if let children = userProfile?.children {
            
            let child = children[indexPath.row]
            cell.showParentName(child.child_firstname, showImage: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
}

//MARK:- ParentDetailCellDelegate

extension AccountSettingsVC: ParentDetailCellDelegate {
    
    func parentDetailCell(_ cell: ParentDetailCell) {
        
        if let indexpath = tableView.indexPath(for: cell), let profile = userProfile {
            
            let editChild = EditChildNameVC(indexpath.row, userProfile: profile)
            navigationController?.pushViewController(editChild, animated: true)
        }
    }
}


//MARK:- TextFieldDelegate

extension AccountSettingsVC : PreeloTextFieldDelegate {
    
    func textFieldReturned(_ textField: PreeloTextField) {
        
        if firstName.isFirstResponder {
            
            lastName.becomeFirstResponder()
        } else if lastName.isFirstResponder {
            
            phoneNumber.becomeFirstResponder()
        } else if phoneNumber.isFirstResponder {
            
            emailAddress.becomeFirstResponder()
        } else if emailAddress.isFirstResponder {
            
            callAPI()
        }
    }
}

// Mark:-  Private Func

extension AccountSettingsVC {
    
    fileprivate func setup () {
        
        childrenInfoButton.isHidden = StaticContentFile.isDoctorLogIn()
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        
        tableView.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        StaticContentFile.setButtonFont(saveButton, shadowNeeded: false)
        StaticContentFile.setButtonFont(discardChangeButton, backgroundColorNeeed: false, shadowNeeded: false)
        customNavigation.setTitle("Account Settings")
        customNavigation.delegate = self
        
        firstName.isCompleteBoarder = true
        password.isCompleteBoarder = true
        confirmPassword.isCompleteBoarder = true
        lastName.isCompleteBoarder = true
        emailAddress.isCompleteBoarder = true
        phoneNumber.isCompleteBoarder = true
        
        tableView.tableFooterView = UIView()
        
        firstName.selectAll(self)
        lastName.selectAll(self)
        confirmPassword.selectAll(self)
        emailAddress.selectAll(self)
        phoneNumber.selectAll(self)
        password.selectAll(self)
        
        firstName.copy(self)
        lastName.copy(self)
        confirmPassword.copy(self)
        emailAddress.copy(self)
        phoneNumber.copy(self)
        password.copy(self)
        
        firstName.textFieldDelegate = self
        lastName.textFieldDelegate = self
        firstName.validateForInputType(.generic, andNotifyDelegate: self)
        lastName.validateForInputType(.generic, andNotifyDelegate: self)
        
        password.textFieldDelegate = self
        confirmPassword.textFieldDelegate = self
        password.validateForInputType(.generic, andNotifyDelegate: self)
        confirmPassword.validateForInputType(.generic, andNotifyDelegate: self)
        
        emailAddress.textFieldDelegate = self
        phoneNumber.textFieldDelegate = self
        emailAddress.validateForInputType(.email, andNotifyDelegate: self)
        phoneNumber.validateForInputType(.mobile, andNotifyDelegate: self)
        
        StaticContentFile.setFontForTF(firstName, autoCaps:  true)
        StaticContentFile.setFontForTF(lastName, autoCaps:  true)
        StaticContentFile.setFontForTF(phoneNumber)
        StaticContentFile.setFontForTF(emailAddress, autoCaps:  false)
        
        personalButtonSelected(true)
        
        userProfile = StaticContentFile.getUserProfile()
        
        setDefaultValue()
    }
    
    fileprivate func setDefaultValue() {
        
        if let profile = userProfile {
            
            firstName.text = profile.firstname
            lastName.text = profile.lastname
            emailAddress.text = profile.email
            phoneNumber.text = profile.phonenumber
            confirmPassword.text = ""
            password.text = ""
        }
        
        self.view.endEditing(true)
    }
    
    fileprivate func personalButtonSelected(_ status: Bool) {
        
        self.view.endEditing(true)
        scrollView.isHidden = !status
        tableView.isHidden  = status
        personalInfoButton.isSelected = status
        childrenInfoButton.isSelected       = !status
        selection = status ? .personalInfo : .childrenListInfo
        personalInfoButton.backgroundColor =  status ? UIColor.clear : UIColor.colorWithHex(0xE6FAFE)
        childrenInfoButton.backgroundColor = status ? UIColor.colorWithHex(0xE6FAFE) : UIColor.clear
        childrenInfoButton.titleLabel?.textColor = status ? UIColor.colorWithHex(0xA7A9AC) : UIColor.colorWithHex(0x40AABB)
        personalInfoButton.titleLabel?.textColor = status ? UIColor.colorWithHex(0x40AABB) : UIColor.colorWithHex(0xA7A9AC)
        childrenInfoButton.titleLabel?.font = status ? UIFont(name: "Ubuntu", size: 12)! : UIFont(name: "Ubuntu-Bold", size: 12)!
        personalInfoButton.titleLabel?.font = status ? UIFont(name: "Ubuntu-Bold", size: 12)! : UIFont(name: "Ubuntu", size: 12)!
    }
    
    fileprivate func callAPI() {
        
        if let fName = self.firstName.text,
            fName.characters.count > 0,
            let lName = self.lastName.text,
            lName.characters.count > 0,
            let phone = self.phoneNumber.text,
            phone.characters.count > 0,
            let email = self.emailAddress.text,
            email.characters.count > 0, Reachability.forInternetConnection().isReachable() {
            
            self.view.isUserInteractionEnabled = false
            activityIndicator?.startAnimating()
            
            Alamofire.request(SettingRouter.post_updateProfile(fName, lName, phone, email, password.text, confirmPassword.text))
                .responseObject { (response: DataResponse<SuccessStatus>) in
                    
                    if let result = response.result.value, result.status == "SUCCESS"  {
                        
                        if let profile = self.userProfile {
                            
                            profile.firstname = fName
                            profile.lastname = lName
                            profile.phonenumber = phone
                            profile.email = email
                            self.userProfile = profile
                            
                            let defaults = UserDefaults.standard
                            let encodedData = NSKeyedArchiver.archivedData(withRootObject: profile)
                            defaults.set(encodedData, forKey: "userProfile")
                            defaults.synchronize()
                        }
                        
                        if let vc = self.navigationController?.viewControllerWithClass(AccountSettingsVC.self) as?  AccountSettingsVC {
                            
                            vc.refresh()
                        }
                    } else {
                        
                        self.view.showToast(message: "Failed to send the feedback")
                    }
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator?.stopAnimating()
            }
        } else if !Reachability.forInternetConnection().isReachable() {
            
            self.view.showToast(message: "Please check the internet connection")
        } else {
            
            self.view.showToast(message: "Please enter the required field")
        }
    }
}

// Mark:-  IBActions Func

extension AccountSettingsVC {
    
    @IBAction func discardChanges(_ sender: Any) {
        
        setDefaultValue()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        callAPI()
    }
    
    @IBAction func PersonalBUttonAction(_ sender: Any) {
        
        self.personalButtonSelected(true)
    }
    
    @IBAction func childernListInfoButtonAction(_ sender: Any) {
        
        self.personalButtonSelected(false)
    }
}

//MARK:- KeyBoard delegate methods

extension AccountSettingsVC {
    
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
