//
//  TermAndConditionVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 12/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class TermAndConditionVC: UIViewController {

    
    @IBOutlet weak fileprivate var customNavigation: CustomNavigationBar!
    @IBOutlet weak var goBackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        StaticContentFile.setButtonFont(goBackButton, backgroundColorNeeed: false)
        self.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func goBackButtonTapped(_ sender: Any) {
   
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setup(){
    customNavigation.setTitle("Terms and Conditions")
    customNavigation.delegate = self
        
    }
}

extension TermAndConditionVC:CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        
        self.navigationController?.popViewController(animated: true)
    }
}








