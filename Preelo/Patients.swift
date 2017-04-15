//
//  Patients.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class Patients: Mappable {
    
    var firstname         = ""
    var lastname          = ""
    var doctorid          = 0
    var id                = 0
    var patientList       = [PatientList]()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        firstname         <- map["firstname"]
        lastname          <- map["lastname"]
        doctorid          <- map["doctorid"]
        id                <- map["id"]
        patientList       <- map["patients"]
    }
}
