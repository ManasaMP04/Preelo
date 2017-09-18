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
                    
                    self.connectToServer(completionHandler: { (userList, success, eventName: String) -> Void in
                    })
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
    
    func connectToServer(completionHandler: @escaping (_ userList: [String: Any]?, _ success: Bool, _ eventName: String) -> Void) {
        
        for skt in webSocket {
            
            skt.onAny { ( event) -> Void in
                
                var dict = event.items?[0] as? [String: Any]
                dict?["eventName"] = event.event
                
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedRaceResultNotification"), object: nil, userInfo: dict)
            }
        }
    }
}
