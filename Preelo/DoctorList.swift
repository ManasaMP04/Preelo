//
//  DoctorList.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class DoctorList: Mappable {
    
    var parent_id         = 0
    var doctorid          = 0
    var doctor_firstname  = ""
    var doctor_lastname                = ""
    var blocked           = ""
    var locations          = [Locations]()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        parent_id         <- map["parent_id"]
        doctorid          <- map["doctorid"]
        doctor_firstname  <- map["doctor_firstname"]
        doctor_lastname   <- map["doctor_lastname"]
        blocked           <- map["block_flag"]
        locations         <- map["locations"]
    }
}
