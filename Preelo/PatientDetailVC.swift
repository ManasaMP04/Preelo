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
    
    func showParentDetailView(_ dict: [[String: String]]) {
        
        addPatientVC.showParentDetailView(dict)
    }
    
    fileprivate func callApi() {
        
        if patients.count == 0 {
            
            addPatientVC = AddPatientVC(false)
            addPatientVC.delegate = self
            addSubViewToView(addPatientVC.view)
        } else {
            
            patientListVC = PatientListVC()
            addSubViewToView(patientListVC.view)
        }
    }
    
    fileprivate func addSubViewToView(_ subView : UIView) {
        
        view.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        AutoLayoutHelper.addTopSpaceConstraintToView(subView, topSpace: 0)
        AutoLayoutHelper.addBottomSpaceConstraintToView(subView, bottomSpace: 0)
        AutoLayoutHelper.addLeadingSpaceConstraintToView(subView, leadingSpace: 0)
        AutoLayoutHelper.addTrailingSpaceConstraintToView(subView, trailingSpace: 0)
    }
}

//MARK:- AddPatientVCDelegate

extension PatientDetailVC: AddPatientVCDelegate {
    
    func pushParentDetailVCFromVC(_ addGuestVC: AddPatientVC, parentInfo: [[String: String]], index: Int) {
        
        let parentDetail = ParentDetailVC(parentInfo, index: index)
        
        navigationController?.pushViewController(parentDetail, animated: true)
    }
    
    func tappedDoneButtonFromVC(_ addGuestVC: AddPatientVC) {
        
        let alertVC = AlertVC()
        alertVC.delegate = self
        navigationController?.pushViewController(alertVC, animated: true)
    }
}

//MARK:- AddPatientVCDelegate

extension PatientDetailVC: AlertVCDelegate {
    
    func tappedDoneButton(_ alertVC: AlertVC) {
        
        _ = navigationController?.popToRootViewController(animated: true)
        
        if addPatientVC != nil {
            
            addPatientVC.view.removeFromSuperview()
        }
        
        if patientListVC == nil {
            
            patientListVC = PatientListVC()
            patientListVC.delegate = self
            addSubViewToView(patientListVC.view)
        } else {
        
            patientListVC.reloadData()
        }
    }
}

//MARK:- PatientListVCDelegate

extension PatientDetailVC: PatientListVCDelegate {
    
    func editButtonTappedFromVC(_ addGuestVC: PatientListVC) {
        
        let addpatientVC = AddPatientVC(true)
        addpatientVC.delegate = self
        navigationController?.pushViewController(addpatientVC, animated: true)
    }
}
