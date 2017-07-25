//
//  locations.swift
//  Preelo
//
//  Created by Manasa MP on 26/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class Locations: Mappable {
    
    var address1        = ""
    var doctorid        = 0
    var address2        = ""
    var id              = 0
    var city            = ""
    var state           = ""
    var cdate           = ""
    var udate           = ""
    var phones          = [DoctorPhoneNumbers]()
    var country         = ""
    var cwho            = 0
    var uwho            = 0

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        address1         <- map["address1"]
        doctorid         <- map["doctor_id"]
        address2         <- map["doctor_firstname"]
        id               <- map["id"]
        state            <- map["state"]
        city             <- map["city"]
        country          <- map["country"]
        cdate            <- map["cdate"]
        udate            <- map["udate"]
        cwho             <- map["cwho"]
        uwho             <- map["uwho"]
        phones           <- map["phones"]
    }
}
