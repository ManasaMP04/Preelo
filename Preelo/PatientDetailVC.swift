//
//  PatientDetailVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class PatientDetailVC: UIViewController {
    
    fileprivate var list          = [Any]()
    fileprivate var addPatientVC  : AddPatientVC!
    fileprivate var patientListVC : PatientListVC!
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
    var patientDetail : Patients?
    var doctorDetils  = [DoctorList]()
    var isAPIFetched  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func showParentDetailView(_ dict: [[String: String]]) {
        
        addPatientVC.showParentDetailView(dict)
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

//MARK:- Call API

extension PatientDetailVC {
    
    fileprivate func setup() {
        
        if StaticContentFile.isDoctorLogIn() {
            
            isAPIFetched ? showPatientListOrAddPatientVC() :  callApi()
        } else {
            
            if isAPIFetched {
                
                self.patientListVC = PatientListVC(self.doctorDetils)
                self.patientListVC.delegate = self
                self.addSubViewToView(self.patientListVC.view)
            } else {
                
                callApi()
            }
        }
    }
    
    fileprivate func showPatientListOrAddPatientVC () {
        
        if let patients = patientDetail, patients.patientList.count > 0 {
            
            patientListVC = PatientListVC(patients.patientList)
            patientListVC.delegate = self
            addSubViewToView(patientListVC.view)
        } else {
            
            addPatientVC = AddPatientVC(false)
            addPatientVC.delegate = self
            addSubViewToView(addPatientVC.view)
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
    
    fileprivate func callApi() {
        
        if StaticContentFile.isDoctorLogIn() {
            
            Alamofire.request(PatientRouter.get())
                .responseObject { (response: DataResponse<Patients>) in
                    
                    if let result = response.result.value {
                        
                        self.patientDetail = result
                        self.showPatientListOrAddPatientVC ()
                    }}
        } else {
            
            Alamofire.request(DoctorListRouter.get())
                .responseArray(keyPath: "data") { (response: DataResponse<[DoctorList]>) in
                    
                    if let result = response.result.value {
                        
                        self.doctorDetils = result
                        
                        self.patientListVC = PatientListVC(self.doctorDetils)
                        self.patientListVC.delegate = self
                        self.addSubViewToView(self.patientListVC.view)
                    }}}
    }
}
