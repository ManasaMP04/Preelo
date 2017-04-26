//
//  DocAuthorizationRequest.swift
//  Preelo
//
//  Created by Manasa MP on 24/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class DocAuthorizationRequest: Mappable {
    
    var firstname         = ""
    var lastname          = ""
    var relationship      = ""
    var doctorid          = 0
    var patientid         = 0
    var parentid          = 0
    var family_id         = 0

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        firstname          <- map["firstname"]
        lastname           <- map["lastname"]
        relationship       <- map["relationship"]
        doctorid           <- map["doctorid"]
        patientid          <- map["patientid"]
        parentid           <- map["parentid"]
        family_id          <- map["family_id"]
    }
}

