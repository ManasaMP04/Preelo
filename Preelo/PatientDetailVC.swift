
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
    
    fileprivate var newPatient : PatientList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func showParentDetailView(_ list: PatientList) {
        
        addPatientVC.showParentDetailView(list)
    }
}

//MARK:- AddPatientVCDelegate

extension PatientDetailVC: AddPatientVCDelegate {
    
    func pushParentDetailVCFromVC(_ addGuestVC: AddPatientVC, patientData: PatientList, index: Int) {
        
        let parentDetail = ParentDetailVC(patientData, index: index)
        
        navigationController?.pushViewController(parentDetail, animated: true)
    }
    
    func tappedDoneButtonFromVC(_ addGuestVC: AddPatientVC, patientList: PatientList) {
        
        newPatient = patientList
        
        let alertVC = AlertVC()
        
        alertVC.setTitle("New Patient", description: attributeText(withText: patientList.firstname), notificationTitle: "Notification")
        alertVC.delegate = self
        navigationController?.pushViewController(alertVC, animated: true)
    }
}

//MARK:- AddPatientVCDelegate

extension PatientDetailVC: AlertVCDelegate {
    
    func tappedDoneButton(_ alertVC: AlertVC) {
        
        _ = navigationController?.popViewController(animated: true)
        if let patient = newPatient {
            
            callAPIToAddPatient(patient)
        }
    }
}

//MARK:- PatientListVCDelegate

extension PatientDetailVC: PatientListVCDelegate {
    
    func editButtonTappedFromVC(_ addGuestVC: PatientListVC) {
        
        addPatientVC = AddPatientVC(false)
        addPatientVC.delegate = self
        self.navigationController?.pushViewController(addPatientVC, animated: true)
    }
}

//MARK:- Call API

extension PatientDetailVC {
    
    fileprivate func setup() {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationItem.hidesBackButton = true
        
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
        
        _ = navigationController?.popToRootViewController(animated: true)
        
        if let patients = patientDetail, patients.patientList.count > 0 {
            
            if addPatientVC != nil {
                
                addPatientVC.removeFromParentViewController()
            }
            
            patientListVC = PatientListVC(patients.patientList)
            patientListVC.delegate = self
            addSubViewToView(patientListVC.view)
        } else {
            
            if patientListVC != nil {
                
                patientListVC.removeFromParentViewController()
            }
            
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
    
    fileprivate func attributeText(withText text: String) -> NSMutableAttributedString {
        
        let output      = NSMutableAttributedString(string: text)
        let opt = NSMutableAttributedString(string: "Patient")
        
        let attr = [NSFontAttributeName: UIFont(name: "Ubuntu-Mediumd", size: 12)!, NSForegroundColorAttributeName:UIColor.colorWithHex(0x23B5B9)]
        
        let attr1 = [NSFontAttributeName: UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName: UIColor.colorWithHex(0x23B5B9)]
        
        
        opt.addAttributes(attr1, range: NSMakeRange(0, opt.length))
        
        output.addAttributes(attr, range: NSMakeRange(0, output.length))
        
        output.append(NSMutableAttributedString(string: "has been succesfully added to the patients list"))
            
        return output
    }
    
    fileprivate func callApi() {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        if StaticContentFile.isDoctorLogIn() {
            
            Alamofire.request(PatientRouter.get())
                .responseObject(keyPath: "data") { (response: DataResponse<Patients>) in
                    
                    self.activityIndicator?.stopAnimating()
                    
                    if let result = response.result.value {
                        
                        self.patientDetail = result
                        self.showPatientListOrAddPatientVC ()
                    }}
        } else {
            
            Alamofire.request(DoctorListRouter.get())
                .responseArray(keyPath: "data") { (response: DataResponse<[DoctorList]>) in
                    
                    self.activityIndicator?.stopAnimating()
                    
                    if let result = response.result.value {
                        
                        self.doctorDetils = result
                        
                        self.patientListVC = PatientListVC(self.doctorDetils)
                        self.patientListVC.delegate = self
                        self.addSubViewToView(self.patientListVC.view)
                    }}}
    }
    
    fileprivate func callAPIToAddPatient(_ patient: PatientList) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(PatientRouter.post(patient))
            .responseObject { (response: DataResponse<addPatient>) in
                
                self.activityIndicator?.stopAnimating()
                if let _ = response.result.value {
                    
                    self.activityIndicator?.stopAnimating()
                    self.callApi()
                }}
    }
}
