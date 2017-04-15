//
//  StaticContentFile.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class StaticContentFile: NSObject {
    
    static let defaults = UserDefaults.standard
    
    static let buttonFont = UIFont(name: "Ubuntu-Bold", size: 15)!
    
    static func isDoctorLogIn() -> Bool {
        
        return defaults.bool(forKey: "isDoctorLogIn")
    }
    
    static func getToxenAndId() -> (String, Int) {
        
        if let token = defaults.string(forKey: "token")  {
            
            return (token,defaults.integer(forKey: "id"))
        }
        
        return ("",0)
    }
}
