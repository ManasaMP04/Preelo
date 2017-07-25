//
//  DoctorList.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class DoctorList: Mappable {
    
    var status            = ""
    var parent_id         = 0
    var doctorid          = 0
    var doctor_firstname  = ""
    var id                = ""
    var children          = [ChildrenDetail]()
    var blocked           = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        parent_id         <- map["parent_id"]
        doctorid          <- map["doctorid"]
        doctor_firstname  <- map["doctor_firstname"]
        id                <- map["id"]
        children          <- map["children"]
        blocked           <- map["block_flag"]
    }
}
