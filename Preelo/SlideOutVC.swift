//
//  SlideOutVC.swift
//  Preelo
//
//  Created by Manasa MP on 14/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class SlideOutVC: UIViewController {
    
    @IBOutlet fileprivate weak var slideButton      : UIButton!
    @IBOutlet fileprivate weak var profileSetting   : UIButton!
    @IBOutlet fileprivate weak var settings         : UIButton!
    @IBOutlet fileprivate weak var logOut           : UIButton!
    @IBOutlet fileprivate weak var titleLabel       : UILabel!
    @IBOutlet fileprivate weak var sendInvite       : UIButton!
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StaticContentFile.adjustImageAndTitleOffsetsForButton(profileSetting)
        StaticContentFile.adjustImageAndTitleOffsetsForButton(settings)
        StaticContentFile.adjustImageAndTitleOffsetsForButton(sendInvite)
        StaticContentFile.setButtonFont(logOut, shadowNeeded: false)
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        
        titleLabel.text = StaticContentFile.isDoctorLogIn() ? "Welcome Doctor" : String(format: "Welcome %@", StaticContentFile.getName())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func popToLogin() {
        
        StaticContentFile.removeAllKeys()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "navigation")
            
            appDelegate.window?.rootViewController = initialViewController
        }
    }
    
    @IBAction func slideOutButtonTapped(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        let vc = CreateAccount(false)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        if Reachability.forInternetConnection().isReachable() {
            
            activityIndicator?.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            Alamofire.request(LogoutRouter.post())
                .responseObject { (response: DataResponse<logOut>) in
                    
                    self.activityIndicator?.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    if let _ = response.result.value {
                        
                        self.popToLogin()
                    } else if let result = response.result.value {
                        
                        self.view.showToast(message: result.message)
                    } else {
                        
                        self.view.showToast(message: "please try again")
                    }}} else if !Reachability.forInternetConnection().isReachable() {
            
            self.view.showToast(message: "Please check the internet connection")
        }
    }
}
