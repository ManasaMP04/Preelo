//
//  SocketIOManager.swift
//  Preelo
//
//  Created by Manasa MP on 07/09/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    
    fileprivate let defaults  = UserDefaults.standard
    static let sharedInstance = SocketIOManager()
    
    var webSocket = [SocketIOClient]()
    
    override init() {
        
        super.init()
    }
    
    func establishConnection() {
        
        if let servers = defaults.value(forKey: "socketServers") as? [[String: Any]] {
            
            for dict in servers {
                
                if let url = dict["address"] as? String,
                    let UrlForSocket = URL(string: url + "/") {
                    
                    let skt = SocketIOClient( socketURL: UrlForSocket, config: [.connectParams(["token": StaticContentFile.getToken()])])
                    
                    webSocket.append(skt)
                    skt.connect()
                }
            }
        }
    }
    
    func closeConnection() {
        
        for skt in webSocket {
            
            skt.disconnect()
        }
    }
    
    func connectToServer(completionHandler: @escaping (_ userList: [String: AnyObject]?, _ success: Bool, _ eventName: String) -> Void) {
        
        for skt in webSocket {
            
            skt.onAny { ( event) -> Void in
                
                completionHandler(event.items?[0] as? [String: AnyObject], true, event.event)
            }
        }
    }
}
