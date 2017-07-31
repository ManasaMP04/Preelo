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
    var image_url            : Any?
    var thumb_Url            : Any?
    var message_id           = 0
    var senderId             = ""
    var image_upload_status  = ""
    var status               = "u"
    
    init(_ type: String, text: String = "", image: Any?, senderId: String = "", timeInterval: String) {
        
        message_type = type
        message_text = text
        
        if let img = image {
            
            image_url = img
            thumb_Url = img
        }
        
        self.message_date = timeInterval
        self.senderId  = senderId
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message_type        <- map["message_type"]
        message_text        <- map["message_text"]
        message_date        <- map["message_date"]
        image_url           <- map["image_url"]
        message_id          <- map["message_id"]
        image_upload_status <- map["image_upload_status"]
        status              <- map["status"]
        senderId            <- map["person"]
        thumb_Url           <- map["thumbnail_url"]
    }
    
    func modelToDict() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["message_type"] = message_type
        dict["message_text"] = message_text
        dict["message_date"] = message_date
        dict["image_url"] = image_url
        dict["message_id"] = message_id
        dict["status"]  = status
        dict["person"]  = senderId
        dict["thumbnail_url"] = thumb_Url
        
        return dict
    }
}
