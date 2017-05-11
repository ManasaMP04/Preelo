//
//  ChannelDetail.swift
//  Preelo
//
//  Created by Manasa MP on 03/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class ChannelObject: Mappable {
    
    var status      = ""
    var message     = ""
    var data        = [ChannelDetail]()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        status      <- map["status"]
        message     <- map["message"]
        data        <- map["data"]
    }
    
    func modelToDict() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["status"] = status
        dict["message"] = message
        
        var array = [Any]()
        for message in data {
            
            array.append(message.modelToDict())
        }
        dict["data"] = array
        
        return dict
    }
    
}

class ChannelDetail: Mappable {
    
    var channel_name        = ""
    var channel_id          = ""
    var relationship        = ""
    var patientname         = ""
    var doctorname          = ""
    var parentname          = ""
    var parent_initials     = ""
    var doctor_initials     = ""
    var recent_message      = [RecentMessages]()
    var recent_timestamp    = ""
    var unread_count        = 0
    var doctorId            = 0
    var parentId            = 0
    var patientId           = 0
    var auth_status         = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        channel_name        <- map["channel_name"]
        channel_id          <- map["channel_id"]
        relationship        <- map["relationship"]
        patientname         <- map["patientname"]
        doctorname          <- map["doctorname"]
        parentname          <- map["parentname"]
        parent_initials     <- map["parent_initials"]
        doctor_initials     <- map["doctor_initials"]
        recent_message      <- map["recent_message"]
        recent_timestamp    <- map["recent_timestamp"]
        unread_count        <- map["unread_count"]
        doctorId            <- map["doctor_id"]
        parentId            <- map["parent_id"]
        patientId           <- map["patient_id"]
        auth_status         <- map["auth_status"]
    }
    
    func modelToDict() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["channel_name"] = channel_name
        dict["channel_id"] = channel_id
        dict["relationship"] = relationship
        dict["patientname"] = patientname
        dict["parent_initials"] = parent_initials
        dict["doctor_initials"] = doctor_initials
        
        var array = [Any]()
        for message in recent_message {
            
            array.append(message.modelToDict())
        }
        dict["recent_message"] = array
        
        dict["recent_timestamp"] = recent_timestamp
        dict["unread_count"] = unread_count
        
        return dict
    }
    
}
