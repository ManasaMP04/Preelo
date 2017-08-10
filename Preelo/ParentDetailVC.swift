//
//  ParentDetailVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import DXPopover

class ParentDetailVC: UIViewController {
    
    @IBOutlet fileprivate weak var relationButton       : UIButton!
    @IBOutlet fileprivate weak var firstName            : FloatingTextField!
    @IBOutlet fileprivate weak var lastName             : FloatingTextField!
    @IBOutlet fileprivate weak var phoneNumber          : FloatingTextField!
    @IBOutlet fileprivate weak var email                : FloatingTextField!
    @IBOutlet fileprivate weak var doneButton           : UIButton!
    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet fileprivate weak var relationship         : UILabel!
    @IBOutlet fileprivate weak var scrollView           : UIScrollView!
    
    fileprivate let popAnimator   = DXPopover()
    fileprivate var patientList   : PatientList?
    fileprivate var selectedIndex = -1
    fileprivate var edited = false
    
    fileprivate var scrollViewBottomInset : CGFloat! {
        
        didSet {
            
            var currentInset                = self.scrollView.contentInset
            currentInset.bottom             = scrollViewBottomInset
            self.scrollView.contentInset    = currentInset
        }
    }
    
    
    init (_ patientList: PatientList, index: Int) {
        
        self.patientList = patientList
        self.selectedIndex = index
        
        super.init(nibName: "ParentDetailVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func gestureTapped(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func selectRelationButtonTapped(_ sender: Any) {
        
        let relationView    = RelationPickerView()
        relationView.delegate = self
        popAnimator.show(at: firstName, withContentView: relationView, in: self.view)
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        addParent()
    }
    
    fileprivate func getList(_ list: PatientList, family: FamilyList) -> PatientList {
        
        if selectedIndex >= 0 {
            
            list.family.remove(at: selectedIndex)
            list.family.insert(family, at: selectedIndex)
        } else  {
            
            list.family.append(family)
        }
        
        return list
    }
    
    fileprivate func addParent() {
        
        self.view.endEditing(true)
        if let fname = firstName.text, fname.characters.count > 0,
            let lname = lastName.text, lname.characters.count > 0,
            let email = email.text, StaticContentFile.isValidEmail(email),
            let phone = phoneNumber.text, phone.characters.count == 10, let relation = relationship.text, let addPatientVC = navigationController?.viewControllerWithClass(AddPatientVC.self) as? AddPatientVC {
            
            let family = FamilyList(fname, lName: lname, email: email, phone: phone, relation: relation)
            
            if let patient = patientList {
                
                addPatientVC.showParentDetailView(getList(patient, family: family))
                _ = navigationController?.popToViewController(addPatientVC, animated: true)
                
            }
        } else if let email = email.text, StaticContentFile.isValidEmail(email) {
            
            view.showToast(message: "Email Id is invalid")
        } else if let text = phoneNumber.text, text.characters.count < 10 {
            
            view.showToast(message: "Phone number is invalid")
        } else {
            
            view.showToast(message: "Please enter the required fields")
        }
        
    }
    
    fileprivate func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        relationButton.layer.cornerRadius  = 5
        relationButton.layer.borderWidth   = 1
        relationButton.layer.borderColor   = UIColor.lightGray.cgColor
        customNavigationBar.setTitle("New Patient")
        customNavigationBar.delegate = self
        
        firstName.isCompleteBoarder = true
        firstName.textFieldDelegate = self
        lastName.textFieldDelegate = self
        phoneNumber.textFieldDelegate = self
        email.textFieldDelegate = self
        lastName.isCompleteBoarder = true
        phoneNumber.isCompleteBoarder = true
        email.isCompleteBoarder = true
        
        StaticContentFile.setFontForTF(firstName)
        StaticContentFile.setFontForTF(lastName)
        StaticContentFile.setFontForTF(phoneNumber)
        StaticContentFile.setFontForTF(email, autoCaps: false)
        StaticContentFile.setButtonFont(doneButton)
        
        firstName.validateForInputType(.generic, andNotifyDelegate: self)
        lastName.validateForInputType(.generic, andNotifyDelegate: self)
        phoneNumber.validateForInputType(.mobile, andNotifyDelegate: self)
        email.validateForInputType(.email, andNotifyDelegate: self)
        
        self.navigationController?.navigationBar.isHidden = true
        
        if let list = patientList, selectedIndex >= 0, list.family.count >= selectedIndex {
            
            let familyData = list.family[selectedIndex]
            
            firstName.text   = familyData.firstname
            lastName.text    = familyData.lastname
            phoneNumber.text = familyData.phone
            self.email.text  = familyData.email
            relationship.text = familyData.relationship
        }
    }
}

extension ParentDetailVC: RelationPickerViewDelegate {
    
    func relationPickerView(_ view: RelationPickerView, text: String) {
        
        edited = true
        relationship.text = text
        popAnimator.dismiss()
    }
}


extension ParentDetailVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        if edited {
            
            let alertVc = UIAlertController.init(title: "Alert", message: "You will loose unsaved data. Would you like to continue?", preferredStyle: .alert)
            let okAlert = UIAlertAction.init(title: "YES", style: .default, handler: { (action) in
                
                alertVc.dismiss(animated: false, completion: nil)
                 _ = self.navigationController?.popViewController(animated: true)
            })
            
            let noAlert = UIAlertAction.init(title: "NO", style: .default, handler: { (action) in
                
                alertVc.dismiss(animated: true, completion: nil)
            })
            
            alertVc.addAction(okAlert)
            alertVc.addAction(noAlert)
            self.present(alertVc, animated: true, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
}

//MARK:- KeyBoard delegate methods

extension ParentDetailVC {
    
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

extension ParentDetailVC : PreeloTextFieldDelegate {
    
    func textFieldReturned(_ textField: PreeloTextField) {
        
        if firstName.isFirstResponder {
            
            lastName.becomeFirstResponder()
        } else if lastName.isFirstResponder {
            
            phoneNumber.becomeFirstResponder()
        } else if phoneNumber.isFirstResponder {
            
            email.becomeFirstResponder()
        } else {
            
            addParent()
        }
    }
    
    func textFieldEditingChanged(_ textField: PreeloTextField) {
        
        edited = true
    }
}
