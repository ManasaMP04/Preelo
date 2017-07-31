//
//  logIn.swift
//  Preelo
//
//  Created by Manasa MP on 15/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class logIn: Mappable {
    
    var message         = ""
    var status          = ""
    var socketServers   = [socketServer]()
    var token           = ""
    var loginDetail     : LogInDetail?
    var notifications   = [String: String]()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message             <- map["message"]
        status              <- map["status"]
        token               <- map["token"]
        loginDetail         <- map["data"]
        notifications       <- map["notifications"]
        socketServers       <- map["socketservers"]
    }
}

class socketServer: Mappable {
    
    var address         = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        address             <- map["address"]
    }
}

class logOut: Mappable {
    
    var message         = ""
    var status          = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message             <- map["message"]
        status              <- map["status"]
    }
}
