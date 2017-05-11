//
//  RecentMessages.swift
//  Preelo
//
//  Created by Manasa MP on 03/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class RecentMessages: Mappable {
    
    var message_type      = ""
    var message_text      = ""
    var message_date      = ""
    var image_url         = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message_type       <- map["message_type"]
        message_text       <- map["message_text"]
        message_date       <- map["message_date"]
        image_url          <- map["image_url"]
    }
    
    func modelToDict() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["message_type"] = message_type
        dict["message_text"] = message_text
        dict["message_date"] = message_date
        dict["image_url"] = image_url
        
        return dict
    }
}
