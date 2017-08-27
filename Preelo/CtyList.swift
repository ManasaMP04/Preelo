//
//  CityList.swift
//  Preelo
//
//  Created by Manasa MP on 28/08/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class CityList: Mappable {
    
    var city         = [String]()
    var countryCode  = [String]()
    var country   = [String]()
    var state     = [String]()
    var accounts      = [String]()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        city             <- map["city"]
        countryCode              <- map["countryCode"]
        country               <- map["country"]
        state         <- map["state"]
        accounts       <- map["accounts"]
    }
}
