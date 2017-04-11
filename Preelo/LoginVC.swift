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
        self.performSegue(withIdentifier: "logIn", sender: nil)
    }
    
    @IBAction func patientLogin(_ sender: Any) {
        
        isDoctorLogIn = false
        self.performSegue(withIdentifier: "logIn", sender: nil)
    }
}

//MARK:- Private Methods

extension LoginVC {
    
    fileprivate func setup() {
        
        navigationController?.navigationBar.isHidden = true
        if let image = UIImage(named: "Login-BG") {
            
            view.backgroundColor = UIColor.init(patternImage: image)
        }
        
        doctorLogin.layer.cornerRadius  = doctorLogin.frame.size.width / 11
        patientLogin.layer.cornerRadius = doctorLogin.frame.size.width / 11
        
        doctorLogin.titleLabel?.font    = StaticContentFile.buttonFont
        patientLogin.titleLabel?.font   = StaticContentFile.buttonFont
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "logIn" {
        
            let loginVC           = segue.destination as? LoginDetailVC
            loginVC?.isDoctorLogIn = isDoctorLogIn
        }
    }
}
