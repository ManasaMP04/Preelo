//
//  PatientDetailVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class PatientDetailVC: UIViewController {
    
    fileprivate var patients      = [Int]()
    fileprivate var addPatientVC  : AddPatientVC!
    fileprivate var patientListVC : PatientListVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callApi()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    fileprivate func callApi() {
        
        if patients.count == 0 {
            
            addPatientVC = AddPatientVC(false)
            addPatientVC.delegate = self
            addSubViewToView(addPatientVC.view)
        } else {
            
            patientListVC = PatientListVC(patients: patients)
            addSubViewToView(patientListVC.view)
        }
    }
    
    fileprivate func addSubViewToView(_ subView : UIView) {
        
        view.addSubview(subView)
        addPatientVC.view.translatesAutoresizingMaskIntoConstraints = false
        AutoLayoutHelper.addTopSpaceConstraintToView(subView, topSpace: 0)
        AutoLayoutHelper.addBottomSpaceConstraintToView(subView, bottomSpace: 0)
        AutoLayoutHelper.addLeadingSpaceConstraintToView(subView, leadingSpace: 0)
        AutoLayoutHelper.addTrailingSpaceConstraintToView(subView, trailingSpace: 0)
    }
}

//MARK:- AddPatientVCDelegate

extension PatientDetailVC: AddPatientVCDelegate {
    
    func pushParentDetailVCFromVC(_ addGuestVC: AddPatientVC) {
    
        performSegue(withIdentifier: "addParentDetail", sender: nil)
    }
}

//MARK:- ParentDetailVCDelegate

extension PatientDetailVC: ParentDetailVCDelegate {
    
    func showParentDetailFromVC(_ parentDetailVC: ParentDetailVC) {
    
    }
}
