//
//  DoctorPhoneNumbers.swift
//  Preelo
//
//  Created by Manasa MP on 26/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class DoctorPhoneNumbers: Mappable {
    
    var location_id         = 0
    var cwho                = 0
    var uwho                = 0
    var phone_type          = ""
    var id                  = 0
    var phone_number        = ""
    var primary_flag        = ""
    var cdate               = ""
    var udate               = ""
    var fax_number          = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        location_id         <- map["location_id"]
        cwho                <- map["cwho"]
        uwho                <- map["uwho"]
        phone_type          <- map["phone_type"]
        id                  <- map["id"]
        phone_number        <- map["phone_number"]
        primary_flag        <- map["primary_flag"]
        cdate               <- map["cdate"]
        udate               <- map["udate"]
        fax_number          <- map["fax_number"]
    }
}
