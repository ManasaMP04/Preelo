//
//  SuccessStatus.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class SuccessStatus: Mappable {
    
    var message         = ""
    var status          = ""
    var message_id     = 0
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message             <- map["message"]
        status              <- map["status"]
        message_id          <- map["message_id"]
    }
}
