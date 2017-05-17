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
        patientid          <- map["patientid"]
        parentid           <- map["parentid"]
    }
    
    func modelToDict() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["firstname"] = firstname
        dict["lastname"] = lastname
        dict["patientid"] = patientid
        dict["parentid"] = parentid
        
        return dict
    }
}

