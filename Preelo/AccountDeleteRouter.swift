//
//  PatientRouterr.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum AccounrDeleteRouter:  URLRequestConvertible {
    
    case post()
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            return .post
        
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            var relativePath: String
            relativePath = NetworkURL.partentdelet
            url = url.appendingPathComponent(relativePath)
            return url
        
        }()
        
        
        let params: [String: Any] = {
            
            var dict : [String: Any]
            dict = ["token" : StaticContentFile.getToken()]
            return dict
        
        }()
        
        var urlRequest = URLRequest(url: url)
        let encoding   = URLEncoding.queryString
        var encodedRequest : URLRequest!
        
        switch self {
        case .post:
            
            let dict = ["token" : StaticContentFile.getToken()]
            encodedRequest          = try encoding.encode(urlRequest, with: dict)
        default:
            do {
                
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
                urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                
                encodedRequest          = try encoding.encode(urlRequest, with: nil)
            } catch {
                
            }
        }
        
        encodedRequest.httpMethod       = method.rawValue
        encodedRequest.timeoutInterval  = 30
        
        return encodedRequest
    }
}
