//
//  addPatient.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class addPatient: Mappable {
    
    var doctor_first_name     = ""
    var doctor_last_name      = ""
    var family                = [FamilyList]()
    var status                = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        doctor_first_name     <- map["doctor_first_name"]
        doctor_last_name      <- map["doctor_last_name"]
        family                <- map["family"]
        status                <- map["status"]
    
    }
}
