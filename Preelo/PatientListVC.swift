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
    var list = [Any]()
    var patientDetail : Patients?
    var isAPIFetched  = false
    
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
    
    fileprivate func setup() {
        
        customNavigationBar.setTitle("Patients")
        customNavigationBar.delegate = self
        navigationController?.navigationBar.isHidden = true
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
        
        if !isAPIFetched {
            
            callApi()
        }
        
        if StaticContentFile.isDoctorLogIn() {
            
            addPatientButton.isHidden = false
            tableviewBottomConstraint.constant = 70
        } else {
            
            addPatientButton.isHidden = true
            tableviewBottomConstraint.constant = 0
        }
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
        } else  if let _ = list[indexPath.row] as? DoctorList  {
            
            cell.showParentName("", showImage: false, showEdit: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
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

extension PatientListVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

extension PatientListVC {
    
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
}

