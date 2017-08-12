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
    var patientid         = 0
    var parentid          = 0
    
    var family_id         = 0
    var doctorid          = 0
    var doctor_firstname         = ""
    var doctor_lastname          = ""
    
    var title           = ""
    var subtitle        = ""


    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        firstname          <- map["firstname"]
        lastname           <- map["lastname"]
        patientid          <- map["patientid"]
        parentid           <- map["parentid"]
        relationship       <- map["relationship"]
        
        family_id          <- map["family_id"]
        doctorid           <- map["doctorid"]
        doctor_firstname   <- map["doctor_firstname"]
        doctor_lastname    <- map["doctor_lastname"]
        
        title              <- map["title"]
        subtitle           <- map["subtitle"]
        

        
    }
    
    func modelToDict() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["firstname"] = firstname
        dict["lastname"] = lastname
        dict["patientid"] = patientid
        dict["parentid"] = parentid
        dict["relationship"] = relationship
        
        dict["title"]          = title
        dict["subtitle"]    = subtitle
        
        return dict
    }
    
    func modelToDictForParent() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["firstname"] = firstname
        dict["lastname"] = lastname
        dict["patientid"] = patientid
        dict["parentid"] = parentid
        dict["relationship"] = relationship
        
        dict["family_id"] = family_id
        dict["doctorid"] = doctorid
        dict["doctor_firstname"] = doctor_firstname
        dict["doctor_lastname"] = doctor_lastname
        
        dict["title"]          = title
        dict["subtitle"]    = subtitle
        return dict
    }
}

