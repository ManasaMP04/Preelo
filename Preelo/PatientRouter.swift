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
    case post(PatientList)
    case put(PatientList)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            switch self {
            case .get:
                return .get
                
            case .put:
                return .put
                
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
               
            case .put:
                
                 relativePath = NetworkURL.editPatient
                
            default:
                relativePath = NetworkURL.addPatient
            }
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        var urlRequest = URLRequest(url: url)
        let encoding                = URLEncoding.queryString
        var encodedRequest : URLRequest!
        
        let params: [String: Any] = {
            
            var dict : [String: Any]
            
            switch self {
                
            case .post(let list):
                
                dict = ["firstname" : list.firstname,
                        "lastname" : list.lastname,
                        "token" : StaticContentFile.getToken()]
                
                var families = [[String: Any]]()
                
                for family in list.family {
                    
                    let familyDict = ["firstname" : family.firstname,
                                      "lastname" : family.lastname,
                                      "relationship": family.relationship,
                                      "phonenumber": family.phone,
                                      "email" : family.email]
                    
                    families.append(familyDict)
                }
                
                dict["family"] = families
                
                
            default: dict = [:]
            }
            
            return dict
        }()
        
        switch self {
        case .get:
            
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