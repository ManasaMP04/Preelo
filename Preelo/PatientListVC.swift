//
//  PatientListVC.swift
//  Preelo
//
//  Created by Manasa MP on 03/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol PatientListVCDelegate: class {
    
    func editButtonTappedFromVC(_ addGuestVC: PatientListVC)
}


fileprivate let cellHeight = CGFloat(45)

class PatientListVC: UIViewController {
    
    @IBOutlet fileprivate weak var customNavigationBar        : CustomNavigationBar!
    @IBOutlet fileprivate weak var tableView                  : UITableView!
    @IBOutlet fileprivate weak var tableviewBottomConstraint  : NSLayoutConstraint!
    @IBOutlet fileprivate weak var addPatientButton           : UIButton!
    
    fileprivate var list = [Any]()
    
    weak var delegate : PatientListVCDelegate?
    
    init (_ list: [Any]) {
        
        self.list = list
        super.init(nibName: "PatientListVC", bundle: nil)
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
    
    func reloadData() {
        
        tableView.reloadData()
    }
    
    @IBAction func addPatient(_ sender: Any) {
        
        delegate?.editButtonTappedFromVC(self)
    }
    
    fileprivate func setup() {
        
        customNavigationBar.setTitle("Patients")
        customNavigationBar.delegate = self
        
        tableView.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
        
        if StaticContentFile.isDoctorLogIn() {
            
            addPatientButton.isHidden = false
            tableviewBottomConstraint.constant = 140
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
        
        delegate?.editButtonTappedFromVC(self)
    }
}

extension PatientListVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

