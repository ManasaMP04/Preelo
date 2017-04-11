//
//  AddPatientVC.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol AddPatientVCDelegate: class {
    
    func pushParentDetailVCFromVC(_ addGuestVC: AddPatientVC)
}

class AddPatientVC: UIViewController {
    
    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet fileprivate weak var firstName            : FloatingTextField!
    @IBOutlet fileprivate weak var lastName             : FloatingTextField!
    @IBOutlet fileprivate weak var addPatientButton     : UIButton!
    @IBOutlet fileprivate weak var parentInformationView: UIView!
    @IBOutlet fileprivate weak var parentInfoViewHeight : NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableview            : UITableView!
    @IBOutlet fileprivate weak var doneButton           : UIButton!
    
    fileprivate var showBackButton = true
    
    weak var delegate: AddPatientVCDelegate?
    
    init (_ showBackButton: Bool) {
        
        self.showBackButton = showBackButton
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
    
    @IBAction func addPatientButtonTapped(_ sender: Any) {
        
        if firstName.text != "" && lastName.text != "" {
            
            delegate?.pushParentDetailVCFromVC(self)
        } else {
            
            view.showToast(message: "Please enter FirstName and LastName")
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
    
    }
    
    func showParentDetailView() {
    
        
    }
}

//MARK:- Private Meyhods

extension AddPatientVC {
    
    fileprivate func setup() {
        
        if showBackButton {
            
            customNavigationBar.setTitle("New Patient", backButtonImageName: "Back", showBackButton: showBackButton)
        }
        addPatientButton.layer.cornerRadius  = addPatientButton.frame.size.width / 11
        addPatientButton.titleLabel?.font    = StaticContentFile.buttonFont
        
        firstName.isCompleteBoarder = true
        lastName.isCompleteBoarder  = true
    }
}
