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
            
            let image = list.blocked.lowercased() == "y" ? "Tick Green 2x" : "minus"
            
            cell.showParentName(list.doctor_firstname , showImage: false, showEdit: true, image: image)
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
            
            callAPIToSelectDocOrPatient(patient, index: 0, doctorId: detail.doctorid)
        }
    }
}

//MARK:- ParentDetailCellDelegate

extension PatientListVC: ParentDetailCellDelegate {
    
    func parentDetailCell(_ cell: ParentDetailCell) {
        
        if let indexpath = tableView.indexPath(for: cell), let patientList = list as? [PatientList] {
            
            let addPatientVC = AddPatientVC(patientList[indexpath.row])
            self.navigationController?.pushViewController(addPatientVC, animated: true)
        } else if let indexpath = tableView.indexPath(for: cell), let docList = list as? [DoctorList] {
            
            let doctorData = docList[indexpath.row]
            
            let text = doctorData.blocked.lowercased() == "y" ? "Unblock Doctor" : "Block the doctor"
            let image = doctorData.blocked.lowercased() == "y" ? "Tick Green 2x" : "minus"
            
            let deletAccount = DeletAccountAlert.init("Doctors", description: attributeText(withText: doctorData.doctor_firstname), notificationTitle: text, image: image, data: doctorData)
            deletAccount.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
            deletAccount.delegate = self
            self.present(deletAccount, animated: true, completion: nil)
        }
    }
    
    fileprivate func attributeText(withText text: String) -> NSMutableAttributedString {
        
        let output      = NSMutableAttributedString(string: "Are you sure that you want to unblock ")
        
        let opt = NSMutableAttributedString(string: text)
        
        let attr = [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName:UIColor.colorWithHex(0x23B5B9)]
        
        let attr1 = [NSFontAttributeName: UIFont(name: "Ubuntu-Light", size: 12)!, NSForegroundColorAttributeName: UIColor.colorWithHex(0x23B5B9)]
        
        
        opt.addAttributes(attr, range: NSMakeRange(0, opt.length))
        
        output.addAttributes(attr1, range: NSMakeRange(0, output.length))
        
        output.append(opt)
        
        return output
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

//MARK:-  private methods

extension PatientListVC {
    
    fileprivate func callAPIToSelectDocOrPatient(_ data : Any, index: Int, doctorId: Int) {
        
        if let data1 = data as? PatientList {
            
            let family = data1.family[index]
            callAPIToSelect(SelectRouter.patient_select_post(family.patientid, family.id, doctorId), name: data1.firstname, parentId: family.id)
        } else if let _ = data as? DoctorList {
            
        }
    }
    
    fileprivate func callAPIToSelect(_ urlRequest: URLRequestConvertible, name: String, parentId: Int) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(urlRequest)
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                self.activityIndicator?.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    let vc = ChatVC(parentId, name: name)
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
        
        if StaticContentFile.isDoctorLogIn() {
            
            view.bringSubview(toFront: addPatientButton)
            addPatientButton.isHidden = false
        } else {
            
            addPatientButton.isHidden = true
        }
        
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

extension PatientListVC: DeletAccountAlertDelegate{
    
    func tappedYesButton(_ vc: DeletAccountAlert, data:Any?) {
        
        if let detail = data as? DoctorList {
            
            let activityIndicator = UIActivityIndicatorView.activityIndicatorToView(vc.view)
            
            activityIndicator.startAnimating()
            
            let urlRequest = detail.blocked.lowercased() == "y" ?  SettingRouter.pos_docUnBlock(detail.doctorid) : SettingRouter.post_doctBlock(detail.doctorid)
            
            Alamofire.request(urlRequest)
                .responseObject { (response: DataResponse<SuccessStatus>) in
                    
                    activityIndicator.stopAnimating()
                    if let result = response.result.value, result.status == "SUCCESS" {
                        
                        UIView.animate(withDuration: 0.4, animations: {
                            
                            vc.view.showToast(message: result.message)
                        }, completion: { (status) in
                            
                            vc.dismiss(animated: true, completion: nil)
                        })
                        
                    } else {
                        
                        vc.view.showToast(message: "Filed to delete the account")
                    }
            }
        } else {
            
            vc.view.showToast(message: "Some thing went wrong pleae try again")
        }
    }
}
