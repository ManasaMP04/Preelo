//
//  EditChildNameVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 14/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import Alamofire

class EditChildNameVC: UIViewController {
    
    @IBOutlet weak var confirmChangeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var childrenFirstName: FloatingTextField!
    @IBOutlet weak var childrenLastName: FloatingTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var customNavigation: CustomNavigationBar!
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    fileprivate var childDetail : ChildrenDetail!
    fileprivate var selectedIndex = 0
    fileprivate var userProfile : LogInDetail!
    
    init (_ index: Int, userProfile: LogInDetail) {
        
        self.childDetail = userProfile.children[index]
        self.selectedIndex = index
        self.userProfile = userProfile
        
        super.init(nibName: "EditChildNameVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var scrollViewBottomInset : CGFloat! {
        
        didSet {
            
            var currentInset                = self.scrollView.contentInset
            currentInset.bottom             = scrollViewBottomInset
            self.scrollView.contentInset    = currentInset
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func gestureIsTapped(_ sender: Any) {
        
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmChangesButtonTapped(_ sender: Any) {
        
        view.endEditing(true)
        
        callAPI()
    }
}

extension EditChildNameVC {
    
    fileprivate func setup() {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        childrenFirstName.validateForInputType(.generic, andNotifyDelegate: self)
        childrenLastName.validateForInputType(.generic, andNotifyDelegate: self)
        customNavigation.setTitle("Edit Child Name")
        customNavigation.delegate = self
        
        childrenFirstName.selectAll(self)
        childrenLastName.selectAll(self)
        childrenFirstName.copy(self)
        childrenLastName.copy(self)
        
        childrenFirstName.textFieldDelegate = self
        childrenLastName.textFieldDelegate = self
        StaticContentFile.setFontForTF(childrenFirstName, autoCaps: true)
        StaticContentFile.setFontForTF(childrenLastName, autoCaps: true)
        StaticContentFile.setButtonFont(confirmChangeButton, shadowNeeded: false)
        StaticContentFile.setButtonFont(cancelButton, backgroundColorNeeed: false, shadowNeeded: false)
        
        childrenFirstName.isCompleteBoarder = true
        childrenLastName.isCompleteBoarder = true
        
        childrenFirstName.text = childDetail.child_firstname
        childrenLastName.text = childDetail.child_lastname
    }
    
    fileprivate func callAPI() {
        
        if let fName = self.childrenFirstName.text,
            fName.characters.count > 0,
            let lName = self.childrenLastName.text,
            lName.characters.count > 0, Reachability.forInternetConnection().isReachable() {
            
            activityIndicator?.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            Alamofire.request(SettingRouter.post_updateChildren(fName, lName, childDetail.patientid))
                .responseObject { (response: DataResponse<SuccessStatus>) in
                    
                    if let result = response.result.value, result.status == "SUCCESS"  {
                        
                        self.childDetail.child_firstname = fName
                        self.childDetail.child_lastname  = lName
                        self.userProfile.children[self.selectedIndex] = self.childDetail
                        
                        let defaults = UserDefaults.standard
                        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.userProfile)
                        defaults.set(encodedData, forKey: "userProfile")
                        defaults.synchronize()

                        if let vc = self.navigationController?.viewControllerWithClass(AccountSettingsVC.self) as?  AccountSettingsVC {
                            
                            vc.refresh()
                        }
                        
                        self.view.isUserInteractionEnabled = true
                        self.activityIndicator?.stopAnimating()
                    } else {
                        
                        self.view.isUserInteractionEnabled = true
                        self.activityIndicator?.stopAnimating()
                        self.view.showToast(message: "Failed to send the feedback")
                    }
            }
        } else if !Reachability.forInternetConnection().isReachable() {
        
            self.view.showToast(message: "Please check the internet connection")
        }else {
            
            self.view.showToast(message: "Please enter the required field")
        }
    }
}

//MARK:- KeyBoard delegate methods

extension EditChildNameVC {
    
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

extension EditChildNameVC:CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditChildNameVC: PreeloTextFieldDelegate {
    
    func textFieldReturned(_ textField: PreeloTextField) {
        
        if childrenFirstName.isFirstResponder {
            
            childrenLastName.becomeFirstResponder()
        } else if childrenLastName.isFirstResponder {
            
            self.view.endEditing(true)
            callAPI()
        }
    }
}





