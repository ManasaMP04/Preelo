//
//  logIn.swift
//  Preelo
//
//  Created by Manasa MP on 15/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class logIn: Mappable {
    
    var message         = ""
    var status          = ""
    var token           = ""
    var loginDetail     : LogInDetail?
    var notifications   = [String]()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message             <- map["message"]
        status              <- map["status"]
        token               <- map["token"]
        loginDetail         <- map["data"]
        notifications       <- map["notifications"]
    }
}

class logOut: Mappable {
    
    var message         = ""
    var status          = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message             <- map["message"]
        status              <- map["status"]
    }
}
