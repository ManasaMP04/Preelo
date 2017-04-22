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
    
    fileprivate let pickerData    = ["Father", "Mother"]
    fileprivate var patientList   : PatientList?
    fileprivate var selectedIndex = -1
    
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
    
    @IBAction func selectRelationButtonTapped(_ sender: Any) {
        
        pickerViewHeight.constant = 100
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
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
    
    fileprivate func getList(_ list: PatientList, family: FamilyList) -> PatientList {
        
        if selectedIndex >= 0 {
            
            list.family.remove(at: selectedIndex)
            list.family.insert(family, at: selectedIndex)
        } else  {
            
            list.family.append(family)
        }
        
        return list
    }
    
    fileprivate func setup() {

        relationButton.layer.cornerRadius  = 5
        relationButton.layer.borderWidth   = 1
        relationButton.layer.borderColor   = UIColor.black.cgColor
        customNavigationBar.setTitle("New Patient")
        customNavigationBar.delegate = self
        doneButton.layer.cornerRadius  = doneButton.frame.size.width / 11
        doneButton.titleLabel?.font    = StaticContentFile.buttonFont
        pickerView.dataSource = self
        pickerView.delegate   = self
        firstName.isCompleteBoarder = true
        lastName.isCompleteBoarder = true
        phoneNumber.isCompleteBoarder = true
        email.isCompleteBoarder = true
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

extension ParentDetailVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}
