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
    case post_updateChildren(String,String, Int)
    case post_updateProfile(String,String, String, String, String?,String?)
    case post_doctBlock(Int)
    case pos_docUnBlock(Int)
    
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
                
            case .post_updateChildren:
                
                relativePath = NetworkURL.childUpdate
                
            case .post_updateProfile:
                
                relativePath = NetworkURL.updateProfile
                
            case .post_doctBlock:
                
                relativePath = NetworkURL.doctorblock
                
            case .pos_docUnBlock:
                
                relativePath = NetworkURL.doctorunblock
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
                
                let dict : [String: Any] = ["subject": subject, "message": message,
                                            "token" : StaticContentFile.getToken()]
                return dict
                
            case .post_updateChildren(let firstName, let lastName, let Id):
                
                let dict : [String: Any] = ["firstname": firstName, "lastname": lastName,
                                            "token" : StaticContentFile.getToken(),
                                            "patientid": Id]
                return dict
                
            case .post_updateProfile(let firstName, let lastName, let phone, let email, let password, let conPassword):
                
                let dict : [String: Any] = ["firstname": firstName, "lastname": lastName,
                                            "token" : StaticContentFile.getToken(),
                                            "phonenumber": phone,
                                            "email" : email,
                                            "password" : password ?? "",
                                            "confirm_password" : conPassword ?? ""]
                return dict
                
            case .pos_docUnBlock(let Id), .post_doctBlock(let Id):
                
                let dict : [String: Any] = ["doctorid": Id,
                                            "token" : StaticContentFile.getToken()]
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
