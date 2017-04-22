//
//  FamilyList.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class FamilyList: Mappable {
    
    var firstname         = ""
    var lastname          = ""
    var relationship      = ""
    var id                = 0
    var authstatus        = false
    var email             = ""
    var phone             = ""
    
    init(_ fName: String, lName: String, email: String, phone: String, relation: String) {
        
        firstname     = fName
        lastname      = lName
        self.email    = email
        self.phone    = phone
        relationship  = relation
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        firstname          <- map["firstname"]
        lastname           <- map["lastname"]
        relationship       <- map["relationship"]
        id                 <- map["id"]
        authstatus         <- map["authstatus"]
        email              <- map["email"]
        phone              <- map["phonenumber"]
    }
}
