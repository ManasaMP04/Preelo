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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if StaticContentFile.isDoctorLogIn() {
            
            if let item = tabBar.items?[2] {
                
                item.selectedImage = UIImage(named: "Patient-Active")
                item.image         = UIImage(named: "Patient")
            }
        } else {
            
            if let item = tabBar.items?[2] {
                
                item.selectedImage = UIImage(named: "")
                item.image         = UIImage(named: "")
            }
        }
        
        callLogiApi()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    fileprivate func callLogiApi(){
        
        if !StaticContentFile.isDoctorLogIn() {
            
            Alamofire.request(PatientRouter.get())
                .responseObject { (response: DataResponse<Patients>) in
                    
                    if let result = response.result.value,
                        let patientDetail = self.viewControllers?[2] as? PatientDetailVC {
                        
                        patientDetail.patientDetail = result
                        patientDetail.isAPIFetched = true
                    }}
        } else {
            
            Alamofire.request(DoctorListRouter.get())
                .responseArray(keyPath: "data") { (response: DataResponse<[DoctorList]>) in
                    
                    if let result = response.result.value,
                        let patientDetail = self.viewControllers?[2] as? PatientDetailVC {
                        
                        patientDetail.isAPIFetched = true
                        patientDetail.doctorDetils = result
                    }}
        }
    }
}
