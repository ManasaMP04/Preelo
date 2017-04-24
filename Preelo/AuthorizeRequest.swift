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
}
