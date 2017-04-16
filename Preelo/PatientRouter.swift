//
//  PatientRouterr.swift
//  Preelo
//
//  Created by Manasa MP on 16/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum PatientRouter:  URLRequestConvertible {
    
    case get()
    case post(String, String)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            switch self {
            case .get:
                return .get
                
            default:
                return .post
            }
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            var relativePath: String
            
            switch self {
            case .get:
                relativePath = NetworkURL.patientList
                
            default:
                relativePath = NetworkURL.addPatient
            }
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        var urlRequest = URLRequest(url: url)
        let encoding                = URLEncoding.queryString
        var encodedRequest : URLRequest!
        
        switch self {
        case .get:
            
            let dict = ["token" : StaticContentFile.getToken()]
            encodedRequest          = try encoding.encode(urlRequest, with: dict)
        default:
            do {
                
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: [:], options: JSONSerialization.WritingOptions())
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
