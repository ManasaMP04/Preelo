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

fileprivate let cellHeight = CGFloat(70)

struct Address {
    
    var address1 : String
    var address2 : String
    var city : String
    var state: String
    var zip: String
    var phone = [String]()
    var fax  = [String]()
    
    var count : Int {
        
        var i = 1
        
        if fax.count > 0 {
            
            i = i + fax.count
        }
        
        return i + phone.count
    }
}

class PatientListVC: UIViewController {
    
    @IBOutlet fileprivate weak var customNavigationBar        : CustomNavigationBar!
    @IBOutlet fileprivate weak var tableView                  : UITableView!
    @IBOutlet fileprivate weak var tableviewBottomConstraint  : NSLayoutConstraint!
    @IBOutlet fileprivate weak var addPatientButton           : UIButton!
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    fileprivate var list = [Any]()
    fileprivate var docDetail = [Address]()
    fileprivate var patientDetail : Any!
    
    fileprivate var selectedIndex: IndexPath?
    fileprivate var editedPatienIndex : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func addPatient(_ sender: Any) {
        
        editedPatienIndex = nil
        let addPatientVC = AddPatientVC(nil)
        
        self.navigationController?.pushViewController(addPatientVC, animated: true)
    }
    
    func removeSelectedIndex() {
    
        selectedIndex = nil
        tableView?.reloadData()
    }
    
    func refreshTableview(_ data: PatientList) {
        
        if let index = editedPatienIndex {
            
            list[index.section] = data
        } else {
            
            list.append(data)
        }
        
        if let nav = self.parent as? UINavigationController, let tab =  nav.parent as? TabBarVC {
            
            tab.list = list
        }
        
        tableView.reloadData()
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension PatientListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int  {
        
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var row = 1
        
        if let path = selectedIndex, path.section == section {
            
             row += 1
        }
        
        return row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParentDetailCell.cellId, for: indexPath) as! ParentDetailCell
        cell.delegate = self
        
        
        if let data = list[indexPath.section] as? PatientList {
            
            cell.showParentName(data.firstname + " " + data.lastname, showImage: false)
        } else  if let list = list[indexPath.section] as? DoctorList  {
            
            if indexPath.row == 0 {
                
                let image = list.blocked.lowercased() == "y" ? "Unblock" : "Block"
                cell.showParentName(list.doctor_firstname , showImage: false, showEdit: true, image: image, showLocation: true, font: UIFont(name: "Ubuntu", size: 16)!, color: UIColor.colorWithHex(0x414042), showInitial: true, initialText: String(list.doctor_firstname.characters.prefix(1)), isLocationSelected: selectedIndex == indexPath)
            } else {
               
                let cell1 = tableView.dequeueReusableCell(withIdentifier: LocationCell.cellId, for: indexPath) as! LocationCell
                cell1.showLocation(docDetail)
                return cell1
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return cellHeight
        }
        
        return UITableViewAutomaticDimension
    }
}

//MARK:- ParentDetailCellDelegate

extension PatientListVC: ParentDetailCellDelegate {
    
    func parentDetailCell(_ cell: ParentDetailCell) {
        
        if let indexpath = tableView.indexPath(for: cell), let patientList = list as? [PatientList] {
            
            editedPatienIndex = indexpath
            let addPatientVC = AddPatientVC(patientList[indexpath.section])
            self.navigationController?.pushViewController(addPatientVC, animated: true)
        } else if let indexpath = tableView.indexPath(for: cell), let docList = list as? [DoctorList] {
            
            let doctorData = docList[indexpath.section]
            
            let text = doctorData.blocked.lowercased() == "y" ? "Unblock Doctor" : "Block the doctor"
            let image = doctorData.blocked.lowercased() == "y" ? "Unblock" : "Block"
            
            let deletAccount = DeletAccountAlert.init("Doctors", description: attributeText(withText: doctorData.doctor_firstname, block: doctorData.blocked.lowercased() == "n"), notificationTitle: text, image: image, index: indexpath.section)
            deletAccount.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
            deletAccount.delegate = self
            self.present(deletAccount, animated: true, completion: nil)
        }
    }
    
    func parentDetailCellTappedLocation(_ cell: ParentDetailCell) {
        
        if let indexpath = tableView.indexPath(for: cell) {
            
            selectedIndex = (indexpath == selectedIndex ? nil : indexpath)
            docDetail.removeAll()
            
            if selectedIndex != nil,
                let docList = list[indexpath.section] as? DoctorList {
                
                for loc in docList.locations {
                    
                    var phones = [String]()
                    
                    for phone in loc.phones {
                        
                        phones.append(phone.phone_number)
                    }
                    
                    var faxes = [String]()
                    
                    for fax in loc.faxes {
                        
                        faxes.append(fax.fax_number + " " + "(Fax)")
                    }
                    
                    let address = Address(address1: loc.address1, address2: loc.address2, city: loc.city,state: loc.state,zip: "", phone: phones, fax: faxes)
                    docDetail.append(address)
                }
            }
            
            tableView.reloadData()
        }
    }
    
    fileprivate func attributeText(withText text: String, block: Bool) -> NSMutableAttributedString {
        
        let output      =  block ? NSMutableAttributedString(string: "Are you sure that you want to block ") : NSMutableAttributedString(string: "Are you sure that you want to unblock ")
        
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
        self.view.isUserInteractionEnabled = false
        
        Alamofire.request(urlRequest)
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    let vc = ChatVC(parentId, name: name)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if let result = response.result.value {
                    
                    self.view.showToast(message: result.message)
                } else {
                    
                    self.view.showToast(message: "Please try again later")
                }
        }
    }
    
    func callApi() {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        if StaticContentFile.isDoctorLogIn() {
            
            Alamofire.request(PatientRouter.get())
                .responseObject(keyPath: "data") { (response: DataResponse<Patients>) in
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator?.stopAnimating()
                    
                    if let result = response.result.value {
                        
                        self.patientDetail = result
                        self.list = result.patientList
                        
                        if let nav = self.parent as? UINavigationController, let tab =  nav.parent as? TabBarVC {
                            
                            tab.list = self.list
                        }
                        
                        self.tableView.reloadData()
                    }}
        } else {
            
            Alamofire.request(DoctorListRouter.get())
                .responseArray(keyPath: "data") { (response: DataResponse<[DoctorList]>) in
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator?.stopAnimating()
                    
                    if let result = response.result.value {
                        
                        self.patientDetail = result
                        self.list = result
                        self.tableView.reloadData()
                    }}}
    }
    
    fileprivate func setup() {
        
        tableView.estimatedRowHeight = 35
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
        tableView.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: LocationCell.cellId)
        
        if let nav = self.parent as? UINavigationController,
            let tab =  nav.parent as? TabBarVC {
            
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
    
    func tappedYesButton(_ vc: DeletAccountAlert, index:Int?) {
        
        if let ind = index,
            let detail = list[ind] as? DoctorList {
            
            let activityIndicator = UIActivityIndicatorView.activityIndicatorToView(vc.view)
            
            activityIndicator.startAnimating()
            
            let urlRequest = detail.blocked.lowercased() == "y" ?  SettingRouter.pos_docUnBlock(detail.doctorid) : SettingRouter.post_doctBlock(detail.doctorid)
            
            Alamofire.request(urlRequest)
                .responseObject { (response: DataResponse<SuccessStatus>) in
                    
                    activityIndicator.stopAnimating()
                    if let result = response.result.value, result.status == "SUCCESS" {
                        
                        let docDetail = detail
                        docDetail.blocked = detail.blocked.lowercased() == "y" ? "n" : "y"
                        
                        self.list[ind] = docDetail
                        vc.view.showToast(message: result.message)
                        self.tableView.reloadData()
                        
                        if let nav = self.parent as? UINavigationController, let tab =  nav.parent as? TabBarVC {
                            
                            tab.list = self.list
                            vc.dismiss(animated: true, completion: nil)
                            
                        }} else {
                        
                        vc.view.showToast(message: "Filed to block or unblock the doctor")
                    }
            }}
    }
}
