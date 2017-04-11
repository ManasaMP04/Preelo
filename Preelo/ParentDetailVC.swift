//
//  ParentDetailVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class ParentDetailVC: UIViewController {
    
    @IBOutlet fileprivate weak var relationButton       : UIButton!
    @IBOutlet fileprivate weak var firstName            : FloatingTextField!
    @IBOutlet fileprivate weak var lastName             : FloatingTextField!
    @IBOutlet fileprivate weak var phoneNumber          : FloatingTextField!
    @IBOutlet fileprivate weak var email                : FloatingTextField!
    @IBOutlet fileprivate weak var doneButton           : UIButton!
    @IBOutlet fileprivate weak var pickerView           : UIPickerView!
    @IBOutlet fileprivate weak var pickerViewHeight     : NSLayoutConstraint!
    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet fileprivate weak var relationship         : UILabel!
    
    fileprivate let pickerData = ["Father", "Mother"]
    fileprivate var parentList = [[String: String]]()
    fileprivate var selectedIndex = -1
    
    init (_ parentList: [[String: String]], index: Int) {
        
        self.parentList = parentList
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
    
    @IBAction func selectRelationButtonTapped(_ sender: Any) {
        
        pickerViewHeight.constant = 100
    }
    
    fileprivate func showDefaultValue() {
        
        let dict = parentList[selectedIndex]
        
        if let fName = dict["ParentFName"], let lname = dict["ParentLName"],
            let phone = dict["ParentPhoneNo"], let email = dict["Email"] {
            
            firstName.text   = fName
            lastName.text    = lname
            phoneNumber.text = phone
            self.email.text  = email
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        if firstName.text != "" && lastName.text != "" && phoneNumber.text?.characters.count == 10 && email.text != "" {
            
            var dict = [String: String]()
            dict["ParentFName"]   = firstName.text
            dict["ParentLName"]   = lastName.text
            dict["ParentPhoneNo"] = phoneNumber.text
            dict["Email"]         = email.text
            
            if let patientDetailVC = navigationController?.viewControllerWithClass(PatientDetailVC.self) as? PatientDetailVC {
                
                if selectedIndex >= 0 {
                    
                    parentList.remove(at: selectedIndex)
                    parentList.insert(dict, at: selectedIndex)
                } else  {
                    
                    parentList.append(dict)
                }
                
                patientDetailVC.showParentDetailView(parentList)
                _ = navigationController?.popToViewController(patientDetailVC, animated: true)
            }
        } else if firstName.text == "" || lastName.text == "" || phoneNumber.text == "" || email.text == "" {
            
            view.showToast(message: "Please enter the required fields")
        } else if !phoneNumber.isValid() {
            
            view.showToast(message: "Phone number is invalid")
        } else if !email.isValid() {
            
            view.showToast(message: "Email Id is invalid")
        }
    }
    
    fileprivate func setup() {
        
        relationButton.layer.cornerRadius  = 5
        relationButton.layer.borderWidth   = 1
        relationButton.layer.borderColor   = UIColor.black.cgColor
        customNavigationBar.setTitle("New Patient", backButtonImageName: "Back")
        doneButton.layer.cornerRadius  = doneButton.frame.size.width / 11
        doneButton.titleLabel?.font    = StaticContentFile.buttonFont
        pickerView.dataSource = self
        pickerView.delegate   = self
        firstName.isCompleteBoarder = true
        lastName.isCompleteBoarder = true
        phoneNumber.isCompleteBoarder = true
        email.isCompleteBoarder = true
        self.navigationController?.navigationBar.isHidden = true
        
        if selectedIndex >= 0 {
        
            showDefaultValue()
        }
    }
}

//MARK:- UIPickerViewDelegate & UIPickerViewDataSource

extension ParentDetailVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        relationship.text           = pickerData[row]
        pickerViewHeight.constant   = 0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 30
    }
}
