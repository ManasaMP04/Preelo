//
//  AccountSettingsVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 12/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class AccountSettingsVC: UIViewController {

   
    @IBOutlet weak fileprivate var customNavigationBar: CustomNavigationBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    }


    
    
    fileprivate func setup(){
    
    customNavigationBar.setTitle("Account Settings")
    
    }
    
    

}




extension AccountSettingsVC{

    





}










