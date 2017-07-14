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

        // Do any additional setup after loading the view.
    
        // Do any additional setup after loading the view.
        StaticContentFile.setButtonFont(deletAccountButton)
        StaticContentFile.setButtonFont(feedBackSupportButton, backgroundColorNeeed: false)
        StaticContentFile.setButtonFont(termAndConditionButton, backgroundColorNeeed: false)
        
        self.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func feedBackSupportButtonAction(_ sender: Any) {
        
    }
    
    
    @IBAction func termAndConditionButtonAction(_ sender: Any) {
    }
    
    @IBAction func deleteMyAccountButtonAction(_ sender: Any) {
        
        let deletAccount = DeletAccountAlert("test")
        deletAccount.delegate = self
        deletAccount.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
        self.present(deletAccount, animated: true, completion: nil)
    }
    
    
    
    
    fileprivate func setup(){
        
        customNavigationBar.setTitle("Settings")
        
    }
}







//MARK:- AddPatientVCDelegate

extension SettingsViewController:DeletAccountDelegate  {

    func tappedNoButton(_ deletAccountVC: DeletAccountAlert){
        
        
        dismiss(animated: false, completion: nil)
        
    
    }
}



