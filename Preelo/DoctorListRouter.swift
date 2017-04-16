//
//  DoctorListRouter.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum DoctorListRouter:  URLRequestConvertible {
    
    case get()
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
        
             return .get
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            let relativePath = NetworkURL.doctorList
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        let urlRequest = URLRequest(url: url)
        let encoding                = URLEncoding.queryString
        let dict = ["token"         : StaticContentFile.getToken()]
        var encodedRequest          = try encoding.encode(urlRequest, with: dict)
        encodedRequest.httpMethod       = method.rawValue
        encodedRequest.timeoutInterval  = 30
        
        return encodedRequest
    }
}
