//
//  RecentMessages.swift
//  Preelo
//
//  Created by Manasa MP on 03/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class RecentMessages: Mappable {
    
    var message_type         = ""
    var message_text         = ""
    var message_date         = ""
    var image_url            = [String]()
    var message_id           = 0
    var person               = ""
    var image_upload_status  = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message_type        <- map["message_type"]
        message_text        <- map["message_text"]
        message_date        <- map["message_date"]
        image_url           <- map["image_url"]
        message_id          <- map["message_id"]
        person              <- map["person"]
        image_upload_status <- map["image_upload_status"]
    }
    
    func modelToDict() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["message_type"] = message_type
        dict["message_text"] = message_text
        dict["message_date"] = message_date
        dict["image_url"] = image_url
        dict["message_id"] = message_id
        dict["person"] = person
        dict["image_upload_status"] = image_upload_status
        
        return dict
    }
}
