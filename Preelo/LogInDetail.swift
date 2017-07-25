//
//  LogInDetail.swift
//  Preelo
//
//  Created by Manasa MP on 15/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class LogInDetail: NSObject, Mappable,NSCoding {
    
    var id             = 0
    var email          = ""
    var firstname      = ""
    var phonenumber    = ""
    var lastname       = ""
    var doctorid       = ""
    var children       = [ChildrenDetail]()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        id             <- map["id"]
        email          <- map["email"]
        firstname      <- map["firstname"]
        phonenumber    <- map["phonenumber"]
        lastname       <- map["lastname"]
        doctorid       <- map["doctorid"]
        children       <- map["children"]
    }
    
    init(id: Int, firstname: String, phonenumber: String, email: String, lastname: String, doctorid: String, children: [ChildrenDetail]) {
        
        self.id = id
        self.firstname = firstname
        self.phonenumber = phonenumber
        self.email = email
        self.lastname = lastname
        self.doctorid = doctorid
        self.children = children
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(id, forKey: "id")
        aCoder.encode(firstname, forKey: "firstname")
        aCoder.encode(phonenumber, forKey: "phonenumber")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(lastname, forKey: "lastname")
        aCoder.encode(doctorid, forKey: "doctorid")
        aCoder.encode(children, forKey: "children")
    }
    
    required convenience init(coder aDecoder: NSCoder)  {
        
        let id = aDecoder.decodeInteger(forKey: "id")
        let firstname = aDecoder.decodeObject(forKey: "firstname") as? String ?? ""
        let phonenumber = aDecoder.decodeObject(forKey: "phonenumber") as? String ?? ""
        let email = aDecoder.decodeObject(forKey: "email") as? String ?? ""
        let lastname = aDecoder.decodeObject(forKey: "lastname") as? String ?? ""
        let doctorid = aDecoder.decodeObject(forKey: "doctorid") as? String ?? ""
        let children = aDecoder.decodeObject(forKey: "children") as? [ChildrenDetail]  ?? [ChildrenDetail]()
        
        self.init(id: id, firstname: firstname, phonenumber: phonenumber, email: email, lastname: lastname, doctorid: doctorid, children: children)
    }
}
