//
//  AddPatientVC.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol AddPatientVCDelegate: class {
    
    func pushParentDetailVCFromVC(_ addGuestVC: AddPatientVC, patientData: PatientList, index: Int)
    
    func tappedDoneButtonFromVC(_ addGuestVC: AddPatientVC, patientList: PatientList)
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
    
    fileprivate var patientList: PatientList?
    
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
        
        if let fname = firstName.text, let lName = lastName.text,
            fname.characters.count > 0, lName.characters.count > 0  {
            
            if let patient = patientList {
                
                delegate?.pushParentDetailVCFromVC(self, patientData: patient, index: -1)
            } else {
                
                let list = PatientList(fname, lName: lName, familyList: [FamilyList]())
                delegate?.pushParentDetailVCFromVC(self, patientData: list, index: -1)
            }
        } else {
            
            view.showToast(message: "Please enter FirstName and LastName")
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        if let list = patientList {
            
            delegate?.tappedDoneButtonFromVC(self, patientList: list)
        }
    }
    
    func showParentDetailView(_ list: PatientList) {
        
        patientList = list
        tableview.reloadData()
        
        tableviewHeight.constant = tableview.contentSize.height
        parentInfoViewHeight.constant = tableviewHeight.constant + 150
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension AddPatientVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return patientList?.family.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParentDetailCell.cellId, for: indexPath) as! ParentDetailCell
        cell.delegate = self
        
        if let module = patientList?.family[indexPath.row] {
            
            cell.showParentName(module.firstname, showImage: true)
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
        
        if let indexpath = tableview.indexPath(for: cell), let list = patientList {
            
            self.delegate?.pushParentDetailVCFromVC(self, patientData: list, index: indexpath.row)
        }
    }
}

//MARK:- Private Meyhods

extension AddPatientVC {
    
    fileprivate func setup() {
        
        tableview.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
        
        customNavigationBar.setTitle("New Patient")
        customNavigationBar.delegate = self
        
        StaticContentFile.setLayer(addPatientButton)
        addPatientButton.titleLabel?.font    = StaticContentFile.buttonFont
        
        firstName.isCompleteBoarder = true
        lastName.isCompleteBoarder  = true
    }
}

extension AddPatientVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}
