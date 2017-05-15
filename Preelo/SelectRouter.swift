//
//  SelectRouter.swift
//  Preelo
//
//  Created by Manasa MP on 24/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum SelectRouter:  URLRequestConvertible {
    
    case patient_select_post(Int, Int)
    case doc_select_post(Int, Int)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            return .post
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            var relativePath: String
            
            switch self {
                
            case .patient_select_post(_, _):
                
                relativePath = NetworkURL.patientSelect
                
            case .doc_select_post(_, _):
                
                relativePath = NetworkURL.docSelect
            }
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        let params: [String: Any] = {
            
            var dict : [String: Any]
            
            switch self {
                
            case .patient_select_post(let patientId, let id):
                
                dict = ["token"    : StaticContentFile.getToken(),
                        "parentid" : id,
                        "patientid" : patientId]
                
                return dict
                
            case .doc_select_post(let patientId, let id):
                
                dict = ["token"    : StaticContentFile.getToken(),
                        "doctorid" : id,
                        "patientid" : patientId]
                
                return dict
            }
        }()
        
        var urlRequest      = URLRequest(url: url)
        let encoding        = URLEncoding.queryString
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
