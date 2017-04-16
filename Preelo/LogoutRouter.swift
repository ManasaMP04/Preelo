//
//  LogoutRouter.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum LogoutRouter:  URLRequestConvertible {
    
    case post()
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            return .post
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            let relativePath = NetworkURL.logout
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        var urlRequest = URLRequest(url: url)
        let encoding                = URLEncoding.queryString
        
        do {
            
            let dict = ["token"         : StaticContentFile.getToken()]
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        } catch {
            
        }
        
        var encodedRequest          = try encoding.encode(urlRequest, with: nil)
        encodedRequest.httpMethod       = method.rawValue
        encodedRequest.timeoutInterval  = 30
        
        return encodedRequest
    }
}
