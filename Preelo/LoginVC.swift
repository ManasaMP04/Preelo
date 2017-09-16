//
//  ViewController.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet fileprivate weak var doctorLogin              : UIButton!
    @IBOutlet fileprivate weak var patientLogin             : UIButton!
    @IBOutlet fileprivate weak var createAccount            : UIButton!
    
    fileprivate var isDoctorLogIn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func doctorLogin(_ sender: Any) {
        
        isDoctorLogIn = true
        pushVc()
    }
    
    @IBAction func patientLogin(_ sender: Any) {
        
        isDoctorLogIn = false
        
        pushVc()
    }
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        
        let vc = CreateAccount(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func pushVc() {
    
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginDetailVC") as? LoginDetailVC {
            
            vc.isDoctorLogIn = isDoctorLogIn
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK:- Private Methods

extension LoginVC {
    
    fileprivate func setup() {
        
        StaticContentFile.setUnderlineForButton(createAccount, text: "Create Account")
        navigationController?.navigationBar.isHidden = true
        if let image = UIImage(named: "Login-BG") {
            
            view.backgroundColor = UIColor.init(patternImage: image)
        }
        
        StaticContentFile.setButtonFont(doctorLogin)
        StaticContentFile.setButtonFont(patientLogin)
    }
}
