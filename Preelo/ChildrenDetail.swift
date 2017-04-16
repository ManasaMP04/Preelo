//
//  ChildrenDetail.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class ChildrenDetail: Mappable {
    
    var patientid            = 0
    var child_firstname      = ""
    var child_lastname       = ""
    var authstatus           = false
    var relationship         = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        patientid            <- map["patientid"]
        child_firstname      <- map["child_firstname"]
        child_lastname       <- map["child_lastname"]
        authstatus           <- map["authstatus"]
        relationship         <- map["relationship"]
    }
}
