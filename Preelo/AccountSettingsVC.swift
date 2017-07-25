//
//  AccountSettingsVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 12/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

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
    
    fileprivate var selection: Selection = .childrenListInfo
    fileprivate var childrenList   = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        childrenList = ["1"]
        setup ()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh() {
    
        tableView.reloadData()
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
        
        return childrenList.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParentDetailCell.cellId, for: indexPath) as! ParentDetailCell
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
}

//MARK:- ParentDetailCellDelegate

extension AccountSettingsVC: ParentDetailCellDelegate {
    
    func parentDetailCell(_ cell: ParentDetailCell) {
        
        if let indexpath = tableView.indexPath(for: cell) {
            
            let editChild = EditChildNameVC(childrenList[indexpath.row])
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
            
            
        }
    }
}

// Mark:-  Private Func

extension AccountSettingsVC {
    
    fileprivate func setup () {
        
        tableView.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
        
        StaticContentFile.setButtonFont(saveButton, shadowNeeded: false)
        StaticContentFile.setButtonFont(discardChangeButton, backgroundColorNeeed: false, shadowNeeded: false)
        customNavigation.setTitle("Account Settings")
        customNavigation.delegate = self
        firstName.isCompleteBoarder = true
        lastName.isCompleteBoarder = true
        emailAddress.isCompleteBoarder = true
        phoneNumber.isCompleteBoarder = true
        tableView.tableFooterView = UIView()
        
        firstName.textFieldDelegate = self
        lastName.textFieldDelegate = self
        firstName.validateForInputType(.generic, andNotifyDelegate: self)
        lastName.validateForInputType(.generic, andNotifyDelegate: self)
        emailAddress.textFieldDelegate = self
        phoneNumber.textFieldDelegate = self
        emailAddress.validateForInputType(.email, andNotifyDelegate: self)
        phoneNumber.validateForInputType(.mobile, andNotifyDelegate: self)
        
        StaticContentFile.setFontForTF(firstName)
        StaticContentFile.setFontForTF(lastName)
        StaticContentFile.setFontForTF(phoneNumber)
        StaticContentFile.setFontForTF(emailAddress, autoCaps:  false)
        
        personalButtonSelected(true)
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
}

// Mark:-  IBActions Func

extension AccountSettingsVC {
    
    @IBAction func discardChanges(_ sender: Any) {
    
        firstName.text = nil
        lastName.text = nil
        emailAddress.text = nil
        phoneNumber.text = nil
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    
    }
    
    @IBAction func PersonalBUttonAction(_ sender: Any) {
        
        self.personalButtonSelected(true)
    }
    
    @IBAction func childernListInfoButtonAction(_ sender: Any) {
        
        self.personalButtonSelected(false)
    }
}
