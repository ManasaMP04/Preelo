//
//  AuthorizeRouter.swift
//  Preelo
//
//  Created by Manasa MP on 23/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum AuthorizeRouter:  URLRequestConvertible {
    
    case post(ChannelDetail)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            return .post
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            let relativePath = NetworkURL.patientAuthorization
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        let params: [String : Any] = {
            
            switch self {
                
            case .post(let channelDetail):
                
                var dict: [String: Any] = ["token"         : StaticContentFile.getToken(),
                                           "patientid"     : channelDetail.patientId]
                
                let array = [["parentid"      : channelDetail.parentId]]
                
                dict["family"] = array
                
                return dict
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        let encoding                = URLEncoding.queryString
        
        do {
            
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        } catch {
            
        }
        
        var encodedRequest          = try encoding.encode(urlRequest, with: nil)
        encodedRequest.httpMethod       = method.rawValue
        encodedRequest.timeoutInterval  = 30
        
        return encodedRequest
    }
}
