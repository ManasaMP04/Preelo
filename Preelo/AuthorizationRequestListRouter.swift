//
//  AuthorizationRequestListRouter.swift
//  Preelo
//
//  Created by Manasa MP on 24/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum AuthorizationRequestListRouter:  URLRequestConvertible {
    
    case get()
    case approveAuth_post(Int, Int)
    case rejectAuth_post(Int, Int)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            switch self {
                
            case .get():
                return .get
                
            default:
                return .post
            }
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            var relativePath: String
            
            switch self {
                
            case .get():
                
                relativePath = NetworkURL.authRequestList
                
            case .approveAuth_post(_, _):
                
                relativePath = NetworkURL.docApproveAuthorization
                
            case .rejectAuth_post(_, _):
                
                relativePath = NetworkURL.docRejectAuthorization
            }
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        let params: [String: Any] = {
            
            var dict : [String: Any]
            
            switch self {
                
            case .get():
                
                dict = ["token"         : StaticContentFile.getToken()]
                
            case .approveAuth_post(let patientid, let parentid):
                
                dict = ["token"         : StaticContentFile.getToken(),
                        "patientid"     : patientid,
                        "parentid"      : parentid]
                
            case .rejectAuth_post(let patientid, let parentid):
                
                dict = ["token"         : StaticContentFile.getToken(),
                        "patientid"     : patientid,
                        "parentid"      : parentid]
            }
            
            return dict
        }()
        
        var urlRequest = URLRequest(url: url)
        let encoding   = URLEncoding.queryString
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
