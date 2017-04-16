//
//  addFamily.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class addFamily: Mappable {
    
    var firstname         = ""
    var lastname          = ""
    var hash      = ""
    var user_id                = ""
    var email             = ""
    var phone             = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        firstname          <- map["firstname"]
        lastname           <- map["lastname"]
        hash       <- map["relationship"]
        user_id                 <- map["user_id"]
        email              <- map["email"]
        phone              <- map["phone"]
    }
}
