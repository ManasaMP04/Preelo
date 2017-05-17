//
//  PatientList.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class PatientList: Mappable {
    
    var firstname         = ""
    var lastname          = ""
    var family            = [FamilyList]()
    
    init(_ fName: String, lName: String, familyList: [FamilyList]) {
    
        firstname = fName
        lastname  = lName
        family    = familyList
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        firstname             <- map["firstname"]
        lastname              <- map["lastname"]
        family                <- map["family"]
    }
}
