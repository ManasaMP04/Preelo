//
//  SettingsViewController.swift
//  Preelo
//
//  Created by vmoksha mobility on 12/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import Alamofire

class SettingsViewController: UIViewController {
    
    @IBOutlet weak fileprivate var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var deletAccountButton: UIButton!
    @IBOutlet weak var feedBackSupportButton: UIButton!
    @IBOutlet weak var termAndConditionButton: UIButton!
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
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
        
        if StaticContentFile.isDoctorLogIn() {
            
            self.view.showToast(message: "Please contact Helpdesk to delete your account")
        } else {
            
            let deletAccount = DeletAccountAlert.init("Settings", description: NSMutableAttributedString(string: "Are you sure that you want to delete your account. You will lose all your data. "), notificationTitle: "Delete Account", image: "Delete")
            deletAccount.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
            deletAccount.delegate = self
            self.present(deletAccount, animated: true, completion: nil)
        }
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

extension SettingsViewController: DeletAccountAlertDelegate{
    
    func tappedYesButton(_ vc: DeletAccountAlert, index:Int?) {
        
        let activityIndicator = UIActivityIndicatorView.activityIndicatorToView(vc.view)
        
        activityIndicator.startAnimating()
        
        Alamofire.request(SettingRouter.post_accountDelet())
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                activityIndicator.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    if let vc = self.navigationController?.viewControllerWithClass(SlideOutVC.self) as? SlideOutVC {
                        
                        vc.popToLogin()
                    }
                } else {
                    
                    vc.view.showToast(message: "Filed to delete the account")
                }
        }
    }
}

