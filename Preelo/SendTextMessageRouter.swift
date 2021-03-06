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
    
    case post_msgRead(Int)
    
    case post_markdelivered()
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            switch self {
                
            case .get:
                return .get
                
            case .post, .post_msgRead, .post_markdelivered:
                return .post
            }
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            
            var relativePath: String
            
            switch self {
                
            case .post(_):
                
                relativePath = NetworkURL.sendText
                
            case .get(_):
                
                relativePath = NetworkURL.getMessages
                
            case .post_msgRead(_):
                relativePath = NetworkURL.markedRead
                
            case .post_markdelivered:
                
                relativePath = NetworkURL.markdelivered
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
                
                let dict: [String: Any] = ["token" : StaticContentFile.getToken(),
                            "channel_id"  : channelDetail.channel_id,
                            "message_id"  : channelDetail.lastMsgId]
                
                return dict
                
            case .post_msgRead(let id):
                
                let dict: [String: Any] = ["token"         : StaticContentFile.getToken(),
                                           "channel_id"    : id]
                
                return dict
                
                case .post_markdelivered:
                
                    let dict: [String: Any] = ["token"         : StaticContentFile.getToken(),
                                               "mode"    : "all"]
                    
                    return dict
                
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        let encoding                = URLEncoding.queryString
        var encodedRequest : URLRequest!
        
        switch self {
        case .get:
            
            encodedRequest          = try encoding.encode(urlRequest, with: params)
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

