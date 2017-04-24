//
//  SelectChildrenVC.swift
//  Preelo
//
//  Created by Manasa MP on 23/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol SelectChildrenVCDelegate: class {
    
    func selectChildrenVC(_ vc: SelectChildrenVC, selectedChild: ChildrenDetail, docList: DoctorList)
}

class SelectChildrenVC: UIViewController {
    
    @IBOutlet fileprivate weak var tableview        : UITableView!
    @IBOutlet fileprivate weak var tableviewHeight  : NSLayoutConstraint!
    
    fileprivate var childrenList = [ChildrenDetail]()
    fileprivate var docList : DoctorList!
    
    weak var delegate: SelectChildrenVCDelegate?
    
    init (_ docList: DoctorList) {
        
        self.docList = docList
        self.childrenList = docList.children
        
        super.init(nibName: "SelectChildrenVC", bundle: nil)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.reloadData()
        
        if tableview.contentSize.height < self.view.frame.size.height - 200 {
        
            tableviewHeight.constant = tableview.contentSize.height
        } else {
        
            tableviewHeight.constant = self.view.frame.size.height - 200
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension SelectChildrenVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return childrenList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        
        let detail = childrenList[indexPath.row]
        cell.textLabel?.text = detail.child_firstname
        cell.textLabel?.font = UIFont(name: "Ubuntu", size: 14)!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.selectChildrenVC(self, selectedChild: childrenList[indexPath.row], docList: docList)
    }
}
