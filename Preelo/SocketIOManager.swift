//
//  SocketIOManager.swift
//  Preelo
//
//  Created by Manasa MP on 31/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {

    static let sharedInstance = SocketIOManager()
    
    //var socket = SocketIOClient(socketURL: NSURL(string: "http://192.168.1.XXX:3000")!)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
       
        //socket.connect()
    }
    
    
    func closeConnection() {
       
        //socket.disconnect()
    }
}
