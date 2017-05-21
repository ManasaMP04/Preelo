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
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StaticContentFile.setButtonFont(logOut)
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func slideOutButtonTapped(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        
        
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        activityIndicator?.startAnimating()
        
        Alamofire.request(LogoutRouter.post())
            .responseObject { (response: DataResponse<logOut>) in
                
                self.activityIndicator?.stopAnimating()
                
                if let _ = response.result.value {
                    
                    StaticContentFile.removeAllKeys()
                    
                    if let vc = self.navigationController?.viewControllerWithClass( LoginVC.self) as?  LoginVC {
                        
                        _ = self.navigationController?.popToViewController(vc, animated: true)
                    } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        
                        let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "navigation")
                        
                        appDelegate.window?.rootViewController = initialViewController
                    }
                }}
    }
}
