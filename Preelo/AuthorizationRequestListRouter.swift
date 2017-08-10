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
    case channel_get()
    case approveAuth_post(Int, Int)
    case rejectAuth_post(Int, Int)
    case get_patient_AuthRequest()
    case cancel_AuthRequest(Int, Int)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            switch self {
                
            case .get(), .channel_get(), .get_patient_AuthRequest():
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
            case .channel_get() :
                
                relativePath = NetworkURL.channel
            case .approveAuth_post(_, _):
                
                relativePath = NetworkURL.docApproveAuthorization
                
            case .get_patient_AuthRequest():
                
                relativePath = NetworkURL.patientAuthRequest
                
            case .rejectAuth_post(_, _):
                
                relativePath = NetworkURL.docRejectAuthorization
                
            case .cancel_AuthRequest(_, _):
                
                relativePath = NetworkURL.cancelAuthRequest
            }
            
            url = url.appendingPathComponent(relativePath)
            
            return url
        }()
        
        let params: [String: Any] = {
            
            var dict : [String: Any]
            
            switch self {
                
            case .get(), .channel_get(), .get_patient_AuthRequest():
                
                dict = ["token"         : StaticContentFile.getToken()]
                
            case .approveAuth_post(let patientid, let parentid):
                
                dict = ["token"         : StaticContentFile.getToken(),
                        "patientid"     : patientid,
                        "parentid"      : parentid]
                
            case .rejectAuth_post(let patientid, let parentid):
                
                dict = ["token"         : StaticContentFile.getToken(),
                        "patientid"     : patientid,
                        "parentid"      : parentid]
                
            case .cancel_AuthRequest(let patientid, let doctorid):
                
                dict = ["token"         : StaticContentFile.getToken(),
                        "patientid"     : patientid,
                        "doctorid"      : doctorid]
            }
            
            return dict
        }()
        
        var urlRequest = URLRequest(url: url)
        let encoding   = URLEncoding.queryString
        var encodedRequest : URLRequest!
        
        switch self {
        case .get, .channel_get(), .get_patient_AuthRequest():
            
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
