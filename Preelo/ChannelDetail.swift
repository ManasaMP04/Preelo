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
    var channel_id          = 0
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
    var doctor_user_id      = 0
    var isFirstTime         = true
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        channel_id          <- map["channel_id"]
        relationship        <- map["relationship"]
        patientname         <- map["patientname"]
        doctorname          <- map["doctorname"]
        recent_message      <- map["recent_message"]
        recent_timestamp    <- map["recent_timestamp"]
        unread_count        <- map["unread_count"]
        doctorId            <- map["doctor_id"]
        parentId            <- map["parent_id"]
        patientId           <- map["patient_id"]
        auth_status         <- map["auth_status"]
        doctor_user_id      <- map["doctor_user_id"]
        isFirstTime         <- map["isFirstTime"]
        parentname          <- map["parentname"]
    }
    
    func modelToDict() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["channel_id"] = channel_id
        dict["relationship"] = relationship
        dict["patientname"] = patientname
        dict["doctorname"] = doctorname
         dict["parentname"] = parentname
        
        var array = [Any]()
        for message in recent_message {
            
            array.append(message.modelToDict())
        }
        dict["recent_message"] = array
        
        dict["recent_timestamp"] = recent_timestamp
        dict["unread_count"] = unread_count
        dict["doctor_id"] = doctorId
        dict["parent_id"] = parentId
        dict["patient_id"] = patientId
        dict["auth_status"] = auth_status
        dict["doctor_user_id"] = doctor_user_id
        dict["isFirstTime"]  = isFirstTime
        
        return dict
    }
    
}
