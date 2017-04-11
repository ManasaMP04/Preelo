//
//  AddPatientVC.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol AddPatientVCDelegate: class {
    
    func pushParentDetailVCFromVC(_ addGuestVC: AddPatientVC, parentInfo: [[String: String]], index: Int)
    
    func tappedDoneButtonFromVC(_ addGuestVC: AddPatientVC)
}

fileprivate let cellHeight = CGFloat(45)
fileprivate let alertMsgFormat = NSLocalizedString("Patient %@ has been succesfully added to the patients list", comment: "Alert")

class AddPatientVC: UIViewController {
    
    @IBOutlet fileprivate weak var tableviewHeight      : NSLayoutConstraint!
    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet fileprivate weak var firstName            : FloatingTextField!
    @IBOutlet fileprivate weak var lastName             : FloatingTextField!
    @IBOutlet fileprivate weak var addPatientButton     : UIButton!
    @IBOutlet fileprivate weak var parentInformationView: UIView!
    @IBOutlet fileprivate weak var parentInfoViewHeight : NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableview            : UITableView!
    @IBOutlet fileprivate weak var doneButton           : UIButton!
    
    fileprivate var showBackButton = true
    fileprivate var parentList = [[String: String]]()
    
    weak var delegate: AddPatientVCDelegate?
    
    init (_ showBackButton: Bool) {
        
        self.showBackButton = showBackButton
        super.init(nibName: "AddPatientVC", bundle: nil)
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
    
    @IBAction func addPatientButtonTapped(_ sender: Any) {
        
        if firstName.text != "" && lastName.text != "" {
            
            delegate?.pushParentDetailVCFromVC(self, parentInfo: parentList, index: -1)
        } else {
            
            view.showToast(message: "Please enter FirstName and LastName")
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        delegate?.tappedDoneButtonFromVC(self)
    }
    
    func showParentDetailView(_ dict: [[String: String]]) {
        
        parentList = dict
        tableview.reloadData()
        
        tableviewHeight.constant = tableview.contentSize.height
        parentInfoViewHeight.constant = tableviewHeight.constant + 150
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension AddPatientVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return parentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParentDetailCell.cellId, for: indexPath) as! ParentDetailCell
        cell.delegate = self
        
        let dict = parentList[indexPath.row]
        
        if let parentName = dict["ParentFName"] {
            
            cell.showParentName(parentName)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
}

//MARK:- ParentDetailCellDelegate

extension AddPatientVC: ParentDetailCellDelegate {
    
    func parentDetailCell(_ cell: ParentDetailCell) {
        
        if let indexpath = tableview.indexPath(for: cell) {
            
            self.delegate?.pushParentDetailVCFromVC(self, parentInfo: parentList, index: indexpath.row)
        }
    }
}

//MARK:- Private Meyhods

extension AddPatientVC {
    
    fileprivate func setup() {
        
        tableview.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
        
        if showBackButton {
            
            customNavigationBar.setTitle("New Patient", backButtonImageName: "Back", showBackButton: showBackButton)
        }
        
        addPatientButton.layer.cornerRadius  = addPatientButton.frame.size.width / 11
        addPatientButton.titleLabel?.font    = StaticContentFile.buttonFont
        
        firstName.isCompleteBoarder = true
        lastName.isCompleteBoarder  = true
    }
}
