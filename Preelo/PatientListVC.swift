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
    
    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet fileprivate weak var tableView            : UITableView!
    
    fileprivate var patients = [[String: String]]()
    
    weak var delegate : PatientListVCDelegate?
    
    init () {
        
        super.init(nibName: "PatientListVC", bundle: nil)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
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
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension PatientListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParentDetailCell.cellId, for: indexPath) as! ParentDetailCell
        cell.delegate = self
        
//        let dict = patients[indexPath.row]
//        
//        if let parentName = dict["ParentFName"] {
//            
//            cell.showParentName(parentName, showImage: false)
//        }
        
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

