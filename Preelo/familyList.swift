//
//  familyList.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class familyList: Mappable {
    
    var firstname         = ""
    var lastname          = ""
    var relationship      = ""
    var id                = 0
    var authstatus        = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        firstname          <- map["firstname"]
        lastname           <- map["lastname"]
        relationship       <- map["relationship"]
        id                 <- map["id"]
        authstatus         <- map["authstatus"]
    }
}
