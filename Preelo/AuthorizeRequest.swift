//
//  AuthorizeRequest
//  Preelo
//
//  Created by Manasa MP on 23/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import ObjectMapper

class AuthorizeRequest: Mappable {
    
    var message         = ""
    var status          = ""
    var authRequest     = [DocAuthorizationRequest]()
    
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        message             <- map["message"]
        status              <- map["status"]
        authRequest         <- map["data"]
         
    
    }
    
    func modelToDict() -> [String : Any] {
        
        var dict = [String : Any]()
        
        dict["message"] = message
        dict["status"] = status
        
        var array = [Any]()
        for request in authRequest {
            
            array.append(request.modelToDict())
        }
        dict["data"] = array
        
        return dict
    }
    
    func modelToDictForParent() -> [String : Any] {
        
        var dict = [String : Any]()
        
        var array = [Any]()
        for request in authRequest {
            
            array.append(request.modelToDictForParent())
        }
        dict["data"] = array
        
        return dict
    }
}
