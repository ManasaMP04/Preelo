//
//  ParentDetailVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol ParentDetailVCDelegate: class {
    
    func showParentDetailFromVC(_ parentDetailVC: ParentDetailVC)
}

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
    
    weak var delegate: ParentDetailVCDelegate?
    
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
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        if firstName.text != "" && lastName.text != "" && phoneNumber.isValid() && email.isValid() {
            
            let plistManager = PlistManager()
            var dict = [String: Any]()
            dict["ParentFName"]   = firstName.text
            dict["ParentLName"]   = lastName.text
            dict["ParentPhoneNo"] = phoneNumber.text
            dict["Email"]         = email.text
            
            plistManager.setObject(dict, forKey: "parentDetail", inFile: .parentInfo)
            
            delegate?.showParentDetailFromVC(self)
            _ = navigationController?.popViewController(animated: true)
        } else {
        
            view.showToast(message: "Please enter the required fields")
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
