//
//  SendTextMessageRouter.swift
//  Preelo
//
//  Created by Manasa MP on 27/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum SendTextMessageRouter:  URLRequestConvertible {
    
    case post(String)
    
    case get(ChannelDetail)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            switch self {
                
            case .get:
                return .get
                
            case .post:
                return .post
            }
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            
            var relativePath = ""
            
            switch self {
                
            case .get:
               
                relativePath = NetworkURL.getMessages
                
            case .post:
                
                relativePath = NetworkURL.sendText
            }
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        let params: [String: Any] = {
            
            switch self {
            case .post(let text):
                
                let dict = ["token"         : StaticContentFile.getToken(),
                            "message_text"  : text]
                
                return dict
                
            case .get(let channelDetail):
                
                let dict = ["token"         : StaticContentFile.getToken(),
                            "channel_id"  : channelDetail.channel_id]
                
                return dict
            } }()
        
        var urlRequest = URLRequest(url: url)
        let encoding                = URLEncoding.queryString
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

