//
//  LogInDetail.swift
//  Preelo
//
//  Created by Manasa MP on 15/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class LogInDetail: Mappable {
    
    var id             = 0
    var email          = ""
    var firstname      = ""
    var phonenumber    = ""
    var lastname       = ""
    var doctorid       = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        id             <- map["id"]
        email          <- map["email"]
        firstname      <- map["firstname"]
        phonenumber    <- map["phonenumber"]
        lastname       <- map["lastname"]
        doctorid       <- map["doctorid"]
    }
}
