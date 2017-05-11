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
    
    fileprivate(set) var list = [Any]()
    fileprivate(set) var patientDetail : Patients?
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
    
    func showMessageList(_ doctorList: DoctorList) {
        
        if let messageVC = storyboard?.instantiateViewController(withIdentifier: "MessageVC") as? MessageVC {
            
            messageVC.showMessageList(doctorList)
        }
    }
    
    func changeTheItem() {
        
        if StaticContentFile.isDoctorLogIn() {
            
            if let item = tabBar.items?[2] {
                
                item.selectedImage = UIImage(named: "Patient")
                item.image         = UIImage(named: "Patient-Active")
            }
        } else {
            
            if let item = tabBar.items?[2] {
                
                item.selectedImage = UIImage(named: "Doctors-list-icon-Active")
                item.image         = UIImage(named: "Doctors-list-icon")
            }
        }
        
        self.tabBar.isHidden = false
    }
}

//MARK:- Private Methods

extension TabBarVC {
    
    fileprivate func setup() {
        
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
                        
                        self.isAPIFetched = true
                        self.list = result
                    }}}
    }
}

