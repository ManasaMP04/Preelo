//
//  DeletAccountAlert.swift
//  Preelo
//
//  Created by vmoksha mobility on 13/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import Alamofire

class DeletAccountAlert: UIViewController {
    
    @IBOutlet fileprivate weak var yesButton            : UIButton!
    @IBOutlet fileprivate weak var noButton             : UIButton!
    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init (_ title: String) {
        
        super.init(nibName: "DeletAccountAlert", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        
        self.setup()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func yssButtonAction(_ sender: Any) {
        
        activityIndicator?.startAnimating()
        
        Alamofire.request(SettingRouter.post_accountDelet())
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                self.activityIndicator?.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    UIView.animate(withDuration: 0.4, animations: {
                        
                        self.view.showToast(message: result.message)
                    }, completion: { (status) in
                        
                        if let vc = self.navigationController?.viewControllerWithClass(SlideOutVC.self) as? SlideOutVC {
                        
                            vc.popToLogin()
                        }
                    })
            
                } else {
                
                    self.view.showToast(message: "Filed to delete the account")
                }
        }
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}


extension DeletAccountAlert{
    
    fileprivate func setup() {
        
        StaticContentFile.setButtonFont(yesButton, backgroundColorNeeed: true, borderNeeded: false, shadowNeeded:  false)
        StaticContentFile.setButtonFont(noButton, backgroundColorNeeed: false, borderNeeded: true, shadowNeeded:  false)
        
        yesButton.layer.cornerRadius = yesButton.frame.height / 1.9
        noButton.layer.cornerRadius  = noButton.frame.height / 1.9
        customNavigationBar.setTitle("Delete Account")
        customNavigationBar.delegate = self
    }
}

extension DeletAccountAlert: CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        self.dismiss(animated: true, completion: nil)
    }
}




