//
//  SettingsViewController.swift
//  Preelo
//
//  Created by vmoksha mobility on 12/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak fileprivate var customNavigationBar: CustomNavigationBar!
    
    @IBOutlet weak var deletAccountButton: UIButton!
    @IBOutlet weak var feedBackSupportButton: UIButton!
    @IBOutlet weak var termAndConditionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StaticContentFile.setButtonFont(deletAccountButton)
        StaticContentFile.setButtonFont(feedBackSupportButton, backgroundColorNeeed: false, shadowNeeded: false)
        StaticContentFile.setButtonFont(termAndConditionButton, backgroundColorNeeed: false, shadowNeeded: false)
        
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    @IBAction func deleteMyAccountButtonAction(_ sender: Any) {
        
        let deletAccount = DeletAccountAlert("test")
        deletAccount.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
        self.present(deletAccount, animated: true, completion: nil)
    }
    
    fileprivate func setup(){
        
        customNavigationBar.setTitle("Settings")
        customNavigationBar.delegate = self
    }
}

extension SettingsViewController:CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        
        self.navigationController?.popViewController(animated: true)
    }
}


