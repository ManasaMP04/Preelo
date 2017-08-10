//
//  AddPatientVC.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

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
    
    fileprivate var activityIndicator   : UIActivityIndicatorView?
    fileprivate var patientList         : PatientList?
    fileprivate var isEditPatient       = false
    fileprivate var edited              = false
    
    init (_ patientList: PatientList?) {
        
        self.patientList = patientList
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        if let nav = self.parent as? UINavigationController, let tab = nav.parent as? UITabBarController {
            
            tab.tabBar.isHidden = false
        }
    }
    
    @IBAction func tapGestureTapped(_ sender: Any) {
        
        view.endEditing(true)
    }
    
    @IBAction func addPatientButtonTapped(_ sender: Any) {
        
        addPatient ()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        if let patient = patientList {
            
            isEditPatient ? callAPIToEditPatient(patient): callAPIToAddPatient(patient)
        }
    }
    
    func showParentDetailView(_ list: PatientList) {
        
        edited = true
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
            
            pushParentVC(list, index: indexpath.row)
        }
    }
}

//MARK:- Private Meyhods

extension AddPatientVC {
    
    fileprivate func addPatient () {
        
        self.view.endEditing(true)
        if let fname = firstName.text, let lName = lastName.text,
            fname.characters.count > 0, lName.characters.count > 0  {
            
            if let patient = patientList {
                
                pushParentVC(patient, index: -1)
            } else {
                
                let list = PatientList(fname, lName: lName, familyList: [FamilyList]())
                pushParentVC(list, index: -1)
            }
        } else {
            
            view.showToast(message: "Please enter FirstName and LastName")
        }
    }
    
    fileprivate func setup() {
        
        tableview.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
        
        StaticContentFile.setButtonFont(addPatientButton, backgroundColorNeeed: false, shadowNeeded: false)
        StaticContentFile.setButtonFont(doneButton)
        firstName.isCompleteBoarder = true
        lastName.isCompleteBoarder  = true
        
        StaticContentFile.setFontForTF(lastName)
        StaticContentFile.setFontForTF(firstName)
        showDefaultValues()
        
        firstName.textFieldDelegate = self
        lastName.textFieldDelegate = self
        firstName.validateForInputType(.generic, andNotifyDelegate: self)
        lastName.validateForInputType(.generic, andNotifyDelegate: self)
    }
    
    fileprivate func showDefaultValues() {
        
        if let list = patientList {
            
            firstName.text = list.firstname
            lastName.text  = list.lastname
            
            showParentDetailView(list)
            edited = false
            isEditPatient = true
            customNavigationBar.setTitle("Edit Patient")
        } else {
            
            isEditPatient = false
            customNavigationBar.setTitle("New Patient")
        }
        
        customNavigationBar.delegate = self
    }
    
    fileprivate func attributeText(withText text: String, isEdit: Bool) -> NSMutableAttributedString {
        
        let output      = NSMutableAttributedString(string: text)
        let opt = NSMutableAttributedString(string: "Patient")
        
        let attr = [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName:UIColor.colorWithHex(0x23B5B9)]
        
        let attr1 = [NSFontAttributeName: UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName: UIColor.colorWithHex(0x23B5B9)]
        
        
        opt.addAttributes(attr1, range: NSMakeRange(0, opt.length))
        
        output.addAttributes(attr, range: NSMakeRange(0, output.length))
        
        if isEdit {
            
            output.append(NSMutableAttributedString(string: " has been succesfully edited"))
        } else {
            output.append(NSMutableAttributedString(string: " has been succesfully added to the patients list"))
        }
        
        return output
    }
    
    fileprivate func showAlertView(_ isEdit: Bool) {
        
        if let list = patientList  {
            
            let alertVC = AlertVC("New Patient", description: attributeText(withText: list.firstname,  isEdit: isEdit), notificationTitle: "Notification", isHideCustomeNavigation: true, navigation: self.parent)
            alertVC.delegate = self
            alertVC.providesPresentationContextTransitionStyle = true;
            alertVC.definesPresentationContext = true;
            alertVC.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    fileprivate func callAPIToAddPatient(_ patient: PatientList) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        Alamofire.request(PatientRouter.post(patient))
            .responseObject { (response: DataResponse<addPatient>) in
                
                self.activityIndicator?.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if let _ = response.result.value {
                    
                    self.showAlertView(false)
                } else {
                    
                    self.view.showToast(message: "Patient Add is failed")
                }}
    }
    
    fileprivate func callAPIToEditPatient(_ patient: PatientList) {
        
        if let fname = firstName.text,
            let lname = lastName.text {
            
            patient.firstname = fname
            patient.lastname  = lname
        }
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(PatientRouter.editPatient(patient))
            .responseObject { (response: DataResponse<addPatient>) in
                
                self.activityIndicator?.stopAnimating()
                if let _ = response.result.value {
                    
                    self.showAlertView(true)
                } else {
                    
                    self.view.showToast(message: "Patient Edit is failed")
                }}.responseString { (str) in
                    
                    print(str)
        }
    }
    
    fileprivate func pushParentVC(_ list: PatientList, index: Int) {
        
        let parentDetail = ParentDetailVC(list, index: index)
        
        navigationController?.pushViewController(parentDetail, animated: true)
    }
}

extension AddPatientVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        if edited {
            
            let alertVc = UIAlertController.init(title: "Alert", message: "You will loose unsaved data. Would you like to continue?", preferredStyle: .alert)
            let okAlert = UIAlertAction.init(title: "YES", style: .default, handler: { (action) in
                
                alertVc.dismiss(animated: false, completion: nil)
                _ = self.navigationController?.popViewController(animated: true)
            })
            
            let noAlert = UIAlertAction.init(title: "NO", style: .default, handler: { (action) in
                
                alertVc.dismiss(animated: true, completion: nil)
            })
            
            alertVc.addAction(okAlert)
            alertVc.addAction(noAlert)
            self.present(alertVc, animated: true, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
}

//MARK:- AddPatientVCDelegate

extension AddPatientVC: AlertVCDelegate {
    
    func tappedDoneButton(_ alertVC: AlertVC) {
        dismiss(animated: false, completion: nil)
        
        if let vc = navigationController?.viewControllerWithClass(PatientListVC.self) as?  PatientListVC, let data = patientList {
            
            vc.refreshTableview(data)
            _ = navigationController?.popToViewController(vc, animated: true)
        }
    }
}

//MARK:- TextFieldDelegate

extension AddPatientVC : PreeloTextFieldDelegate {
    
    func textFieldReturned(_ textField: PreeloTextField) {
        
        if firstName.isFirstResponder {
            
            lastName.becomeFirstResponder()
        } else if lastName.isFirstResponder {
            
            addPatient ()
        }
    }
    
    func textFieldEditingChanged(_ textField: PreeloTextField) {
        
        edited = true
    }
}

