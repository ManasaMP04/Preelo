//
//  SettingRouter.swift
//  Preelo
//
//  Created by vmoksha mobility on 18/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum SettingRouter:  URLRequestConvertible {
    
    case post_accountDelet()
    case post_feedbackSupport(String,String)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {

            return .post
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            var relativePath: String
            
            switch self{
            
            case .post_accountDelet:
                
                relativePath = NetworkURL.partentdelet
            
            case .post_feedbackSupport:

                relativePath = NetworkURL.feedback
            }
            
            url = url.appendingPathComponent(relativePath)
            return url
            
        }()
        
        
        let params: [String: Any] = {
            
            switch self{
            
            case .post_accountDelet:
                
                var dict : [String: Any]
                dict = ["token" : StaticContentFile.getToken()]
                return dict

            case .post_feedbackSupport(let subject, let message):
                
                let dict : [String: Any] = ["subject": subject, "message": message]
                return dict
            
            }
            
        }()
        
        var urlRequest = URLRequest(url: url)
        let encoding   = URLEncoding.queryString
        var encodedRequest : URLRequest!
        
        do {
            
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            encodedRequest          = try encoding.encode(urlRequest, with: nil)
        } catch {
            
        }
        
        encodedRequest.httpMethod       = method.rawValue
        encodedRequest.timeoutInterval  = 30
        
        return encodedRequest
    }
}
