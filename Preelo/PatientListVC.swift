//
//  PatientListVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

fileprivate let cellHeight = CGFloat(45)

class PatientListVC: UIViewController {
    
    @IBOutlet fileprivate weak var customNavigationBar        : CustomNavigationBar!
    @IBOutlet fileprivate weak var tableView                  : UITableView!
    @IBOutlet fileprivate weak var tableviewBottomConstraint  : NSLayoutConstraint!
    @IBOutlet fileprivate weak var addPatientButton           : UIButton!
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    fileprivate var list = [Any]()
    fileprivate var patientDetail : Any!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func addPatient(_ sender: Any) {
        
        let addPatientVC = AddPatientVC(nil)
        
        self.navigationController?.pushViewController(addPatientVC, animated: true)
    }
    
    func refreshTableview(_ data: PatientList) {
        
        list.append(data)
        tableView.reloadData()
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension PatientListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParentDetailCell.cellId, for: indexPath) as! ParentDetailCell
        cell.delegate = self
        
        if let data = list[indexPath.row] as? PatientList {
            
            cell.showParentName(data.firstname, showImage: false)
        } else  if let list = list[indexPath.row] as? DoctorList  {
            
            cell.showParentName(list.doctor_firstname , showImage: false, showEdit: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if StaticContentFile.isDoctorLogIn(),
            let patient = list[indexPath.row] as? PatientList,
            let detail  = patientDetail as? Patients,
            patient.family.count > 0 {
            
            callAPIToSelectDocOrPatient(patient, index: 0, id: detail.doctorid)
        }
    }
}

//MARK:- ParentDetailCellDelegate

extension PatientListVC: ParentDetailCellDelegate {
    
    func parentDetailCell(_ cell: ParentDetailCell) {
        
        if let indexpath = tableView.indexPath(for: cell), let patientList = list as? [PatientList] {
            
            let addPatientVC = AddPatientVC(patientList[indexpath.row])
            self.navigationController?.pushViewController(addPatientVC, animated: true)
        }
    }
}

//MARK:-  CustomNavigationBarDelegate

extension PatientListVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        if let nav = self.parent as? UINavigationController, let tab = nav.parent as? UITabBarController {
            
            tab.selectedIndex = 0
        }
    }
}

//MARK:-  SelectChildrenVCDelegate

extension PatientListVC: SelectChildrenVCDelegate {
    
    func selectChildrenVC(_ vc: SelectChildrenVC, list: Any, index: Int) {
        
        if let detail  = patientDetail as? Patients {
            
            callAPIToSelectDocOrPatient(list, index: index, id: detail.doctorid)
        }
    }
}

//MARK:-  private methods

extension PatientListVC {
    
    fileprivate func callAPIToSelectDocOrPatient(_ data : Any, index: Int, id: Int) {
        
        if let data1 = data as? PatientList {
            
            let family = data1.family[index]
            callAPIToSelect(SelectRouter.patient_select_post(family.patientid, family.id, id), id: family.patientid, name: data1.firstname)
        } else if let _ = data as? DoctorList {
            
        }
    }
    
    fileprivate func callAPIToSelect(_ urlRequest: URLRequestConvertible, id: Int, name: String) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(urlRequest)
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                self.activityIndicator?.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    let vc = ChatVC(id, name: name)
                    self.navigationController?.pushViewController(vc, animated: true)
                }}
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
                        self.list = result.patientList
                        self.tableView.reloadData()
                    }}
        } else {
            
            Alamofire.request(DoctorListRouter.get())
                .responseArray(keyPath: "data") { (response: DataResponse<[DoctorList]>) in
                    
                    self.activityIndicator?.stopAnimating()
                    
                    if let result = response.result.value {
                        
                        self.patientDetail = result
                        self.list = result
                        self.tableView.reloadData()
                    }}}
    }
    
    fileprivate func setup() {
        
        view.bringSubview(toFront: addPatientButton)
        StaticContentFile.isDoctorLogIn() ? customNavigationBar.setTitle("Patients") : customNavigationBar.setTitle("Doctors")
        customNavigationBar.delegate = self
        navigationController?.navigationBar.isHidden = true
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
        
        if let nav = self.parent as? UINavigationController, let tab =  nav.parent as? TabBarVC {
            
            if tab.isAPIFetched {
                
                list = tab.list
                patientDetail = tab.patientDetail
            } else {
                callApi()
            }
        } else {
            callApi()
        }
    }
}

