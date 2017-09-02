//
//  LogInRouter.swift
//  Preelo
//
//  Created by Manasa MP on 14/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire
import FirebaseInstanceID

enum LogInRouter : URLRequestConvertible {
    
    case post(String, String)
    
    case doc_post(String, String)
    
    case forgotPassword(String)
    
    case registerDevice()
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            return .post
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            
            var relativePath: String
            
            switch self {
                
            case .post(_, _):
                
                relativePath = NetworkURL.patientLogin
                
            case .doc_post(_, _):
                
                relativePath = NetworkURL.docLogin
                
            case .forgotPassword(_) :
                
                relativePath = NetworkURL.forgotPassword
                
            case .registerDevice :
                
                relativePath = NetworkURL.registerDevice
            }
            
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        let params: [String : Any] = {
            
            switch self {
            case .post(let email, let passwd):
                
                let dict : [String: Any] = ["email": email, "password": passwd]
                
                return dict
                
            case .doc_post(let email, let passwd):
                
                let dict : [String: Any] = ["email": email, "password": passwd]
                
                return dict
                
            case .forgotPassword(let email) :
                
                let dict : [String: Any] = ["email": email]
                
                return dict
                
            case .registerDevice :
                
                let defaults = UserDefaults.standard
                
                var dict : [String: Any] = ["token": StaticContentFile.getToken(), "platform": "IOS"]
                
                if let fcmToken = InstanceID.instanceID().token(), let deviceId =  defaults.value(forKey: "deviceID") {
                    
                    dict["fcm_token"] = fcmToken
                    dict["device_id"] = deviceId
                }
                
                return dict
            }
        }()
        
        
        var urlRequest = URLRequest(url: url)
        
        do {
            
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        } catch {
            
        }
        
        let encoding                = URLEncoding.queryString
        var encodedRequest          = try encoding.encode(urlRequest, with: nil)
        
        encodedRequest.httpMethod       = method.rawValue
        encodedRequest.timeoutInterval  = 30
        
        return encodedRequest
    }
}
