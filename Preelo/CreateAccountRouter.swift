//
//  CreateAccountRouter.swift
//  Preelo
//
//  Created by Manasa MP on 16/09/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

import Foundation
import Alamofire

enum CreateAccountRouter:  URLRequestConvertible {
    
    case createAccount(CreateAccountDetails)
    case invite(CreateAccountDetails)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            return .post
        }
        
        let url: URL = {
            
            var url = URL(string: NetworkURL.baseUrl)!
            var relativePath: String
            
            switch self{
                
            case .createAccount:
                
                relativePath = NetworkURL.createAccount
                
            case .invite:
                
                relativePath = NetworkURL.invite
            }
            
            url = url.appendingPathComponent(relativePath)
            return url
            
        }()
        
        
        let params: [String: Any] = {
            
            switch self{
                
            case .createAccount(let detail) :
                
                var dict : [String: Any]
                dict = ["account_type" : detail.accountType,
                        "firstname": detail.fName,
                        "lastname" : detail.lName,
                        "email" : detail.email,
                        "phone" : detail.phone,
                        "city" :detail.cityName]
                
                if detail.accountType == "Patient" {
                    
                    dict ["doctor_firstname"] = detail.drFName
                    dict ["doctor_lastname"] = detail.drLName
                }
                
                return dict
                
            case .invite(let detail):
                
                var dict : [String: Any]
                dict = ["token" : StaticContentFile.getToken(),
                        "account_type" : detail.accountType,
                        "firstname": detail.fName,
                        "lastname" : detail.lName,
                        "email" : detail.email,
                        "phone" : detail.phone,
                        "city" :detail.cityName]
                if detail.accountType == "Patient" {
                    
                    dict ["doctor_firstname"] = detail.drFName
                    dict ["doctor_lastname"] = detail.drLName
                }
                
                return dict
                
            }}()
        
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
