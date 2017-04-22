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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logOut.layer.cornerRadius  = logOut.frame.size.width / 11
        logOut.titleLabel?.font    = StaticContentFile.buttonFont
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
        
        Alamofire.request(LogoutRouter.post())
            .responseObject { (response: DataResponse<logOut>) in
                
                if let _ = response.result.value {
                    
                    StaticContentFile.removeAllKeys()
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }}
    }
}
