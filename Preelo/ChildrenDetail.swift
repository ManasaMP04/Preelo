//
//  ChildrenDetail.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class ChildrenDetail: NSObject, Mappable, NSCoding {
    
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
    
    init(patientid: Int, child_firstname: String, child_lastname: String, authstatus: Bool, relationship: String) {
        
        self.patientid = patientid
        self.child_firstname = child_firstname
        self.child_lastname = child_lastname
        self.authstatus = authstatus
        self.relationship = relationship
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(patientid, forKey: "patientid")
        aCoder.encode(child_firstname, forKey: "child_firstname")
        aCoder.encode(child_lastname, forKey: "child_lastname")
        aCoder.encode(authstatus, forKey: "authstatus")
        aCoder.encode(relationship, forKey: "relationship")
    }
    
    required convenience init(coder aDecoder: NSCoder)  {
        
        let id = aDecoder.decodeInteger(forKey: "patientid")
        
        let child_firstname = aDecoder.decodeObject(forKey: "child_firstname") as? String ?? ""
        let child_lastname = aDecoder.decodeObject(forKey: "child_lastname") as? String ?? ""
        let authstatus = aDecoder.decodeObject(forKey: "authstatus") as? Bool ?? false
        let relationship = aDecoder.decodeObject(forKey: "relationship") as? String ?? ""
            
        self.init(patientid: id, child_firstname: child_firstname, child_lastname: child_lastname, authstatus: authstatus, relationship: relationship)
    }
}
