//
//  ForgotPassword.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class ForgotPassword: Mappable {
    
    var message         = ""
    var status          = ""
    var hash            = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message             <- map["message"]
        status              <- map["status"]
        hash                <- map["hash"]
    }
}
