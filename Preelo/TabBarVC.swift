//
//  TabBarVC.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class TabBarVC: UITabBarController {
    
    var list = [Any]()
    fileprivate(set) var patientDetail : Any!
    fileprivate(set) var isAPIFetched  = false
    fileprivate var activityIndicator  : UIActivityIndicatorView?
    
    var loginDetail : logIn!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func changeTheItem() {
        
        if StaticContentFile.isDoctorLogIn() {
            
            if let item = tabBar.items?[1] {
                
                item.selectedImage = UIImage(named: "Patient")
                item.image         = UIImage(named: "Patient-Active")
            }
        } else {
            
            if let item = tabBar.items?[1] {
                
                item.selectedImage = UIImage(named: "Doctors-list-icon-Active")
                item.image         = UIImage(named: "Doctors-list-icon")
            }
        }
        
        self.tabBar.isHidden = false
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    }
}

//MARK:- Private Methods

extension TabBarVC {
    
    fileprivate func setup() {
        
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        self.navigationController?.navigationBar.isHidden = true
        callLogiApi()
    }
    
    fileprivate func callLogiApi() {
        
        if StaticContentFile.isDoctorLogIn() {
            
            Alamofire.request(PatientRouter.get())
                .responseObject(keyPath: "data") { (response: DataResponse<Patients>) in
                    
                    if let result = response.result.value {
                        self.isAPIFetched = true
                        self.list = result.patientList
                        self.patientDetail = result
                    }}
        } else {
            
            Alamofire.request(DoctorListRouter.get())
                .responseArray(keyPath: "data") { (response: DataResponse<[DoctorList]>) in
                    
                    if let result = response.result.value {
                        
                        self.patientDetail = result
                        self.isAPIFetched = true
                        self.list = result
                    }}}
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if let nav = self.childViewControllers[0] as? UINavigationController,
            let nav1 = self.childViewControllers[1] as? UINavigationController {
        
            if let vc = nav1.viewControllers[0] as? PatientListVC {
            
                vc.removeSelectedIndex()
            }
            
            if (self.presentedViewController != nil) {
            
                dismiss(animated: true, completion: nil)
            }
            
            nav.popToRootViewController(animated: true)
            nav1.popToRootViewController(animated: true)
            self.tabBar.isHidden = false
        }
    }
}

