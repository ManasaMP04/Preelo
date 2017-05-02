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
    fileprivate var patientDetail : Patients?
    
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
        
        if !StaticContentFile.isDoctorLogIn(), let docList = list[indexPath.row] as? DoctorList, docList.children.count > 0 {
            
            guard docList.children.count > 1 else {
                
                callAPIToSelectDocOrPatient(docList.children[0], docList:docList)
                return
            }
            let vc = SelectChildrenVC(docList)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
            return
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
    
    func selectChildrenVC(_ vc: SelectChildrenVC, selectedChild: ChildrenDetail, docList: DoctorList) {
        
        callAPIToSelectDocOrPatient(selectedChild, docList:docList)
    }
}

//MARK:-  private methods

extension PatientListVC {
    
    fileprivate func callAPIToSelectDocOrPatient(_ selectedChild: ChildrenDetail, docList: DoctorList) {
        
        if StaticContentFile.isDoctorLogIn() {
            
            callAPIToSelect(SelectRouter.post(selectedChild.patientid, docList.parent_id), childrenDetail: selectedChild, docList: docList)
        } else {
            
            callAPIToSelect(SelectRouter.doc_post(selectedChild.patientid, docList.doctorid), childrenDetail: selectedChild, docList: docList)
        }
    }
    
    fileprivate func callAPIToSelect(_ urlRequest: URLRequestConvertible, childrenDetail: ChildrenDetail, docList: DoctorList) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(urlRequest)
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.activityIndicator?.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    let chatvc = ChatVC(docList, childrenDetail: childrenDetail)
                    self.navigationController?.pushViewController(chatvc, animated: true)
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
                        
                        self.list = result
                        self.tableView.reloadData()
                    }}}
    }
    
    fileprivate func setup() {
        
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
        
        if StaticContentFile.isDoctorLogIn() {
            
            addPatientButton.isHidden = false
            tableviewBottomConstraint.constant = 100
        } else {
            
            addPatientButton.isHidden = true
            tableviewBottomConstraint.constant = 0
        }
    }
}

