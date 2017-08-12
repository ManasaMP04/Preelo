//
//  StaticContentFile.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class StaticContentFile: NSObject {
    
    static let defaults         = UserDefaults.standard
    static let screenBounds     = UIScreen.main.bounds
    static let screenWidth      = screenBounds.size.width
    static let screenHeight     = screenBounds.size.height
    static let plistStorageManager = PlistManager()
    
    static func setButtonFont(_ button: UIButton, backgroundColorNeeed: Bool = true, borderNeeded: Bool = true, shadowNeeded: Bool = true) {
        
        button.backgroundColor = backgroundColorNeeed ? UIColor.colorWithHex(0x3DB0BB) : UIColor.clear
        
        button.titleLabel?.font = UIFont(name: "Ubuntu-Bold", size: 12)!
        button.titleLabel?.textColor = backgroundColorNeeed ?  UIColor.white: UIColor.colorWithHex(0x3DB0BB)
        
        if borderNeeded {
            
            button.layer.borderColor = UIColor.colorWithHex(0x3DB0BB).cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = button.frame.size.width / 14
        }
        
        if shadowNeeded {
            
            button.addShadowWithColor(UIColor.black, offset: CGSize(width: 0, height: 4), opacity: 0.4, radius: 5)
        }
    }
    
    static func setFontForTF(_ tf: UITextField, autoCaps: Bool = true) {
        
        tf.textColor              = UIColor(white: 0.2, alpha: 1.0)
        tf.font                   = UIFont(name: "Ubuntu-Light", size: 12)!
        
        tf.autocapitalizationType = autoCaps ? .sentences : .none
        tf.clearButtonMode        = .whileEditing
    }
    
    static func setUnderlineForButton(_ button: UIButton, font: UIFont = UIFont(name: "Ubuntu-Bold", size: 12)!, color: UIColor = UIColor.colorWithHex(0x3DB0BB), text: String) {
        
        let attrs = [ NSFontAttributeName :font, NSForegroundColorAttributeName : color,
                      NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue] as [String : Any]
        
        let str = NSAttributedString(string: text, attributes: attrs)
        button.setAttributedTitle(str, for: .normal)
    }
    
    
    static func isValidEmail(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

//MARK:- remove all userDefalut values and plist

extension StaticContentFile {
    
    static func removeAllKeys() {
        
        plistStorageManager.deleteObject(forKey: "\(StaticContentFile.getId())", inFile: .authRequest)
        defaults.removeObject(forKey: "isDoctorLogIn")
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "id")
        defaults.removeObject(forKey: "name")
        defaults.set(false, forKey: "isLoggedIn")
        defaults.removeObject(forKey: "userProfile")
        defaults.removeObject(forKey: "socketServers")
        StaticContentFile.deleteMessagePlist()
        MessageVC.sharedInstance.closeConnection()
    }
    
    static func deleteMessagePlist() {
        
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        
        let filePath = "\(dirPath)/"+"PlistFiles/message.plist"
        
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
}

//MARK:- save/get other userDefalut values

extension StaticContentFile {
    
    static func isDoctorLogIn() -> Bool {
        
        return defaults.bool(forKey: "isDoctorLogIn")
    }
    
    static func getToken() -> String {
        
        if let token = defaults.string(forKey: "token")  {
            
            return token
        }
        
        return ""
    }
    
    static func getName() -> String {
        
        if let name = defaults.string(forKey: "name")  {
            
            return name
        }
        
        return ""
    }
    
    static func getId() -> Int {
        
        return defaults.integer(forKey: "id")
    }
    
    static func getUserProfile() -> LogInDetail? {
        
        if let decoded  = defaults.object(forKey: "userProfile") as? Data,
            let profile = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? LogInDetail {
            
            return profile
        }
        
        return nil
    }
}

//MARK:- save/get auth

extension StaticContentFile {
    
    static func updateAuthRequest(_ result: DocAuthorizationRequest) {
        
        if let authObject = plistStorageManager.objectForKey("\(StaticContentFile.getId())", inFile: .authRequest) as? [String: Any], let array =  authObject["data"] as? [[String: Any]] {
            
            var authArray = array
            var authObject1 = authObject
            
            for (i,element) in authArray.enumerated() {
                
                if let id = element["patientid"] as? Int, id == result.patientid {
                    
                    authArray.remove(at: i)
                    
                    authObject1["data"] = authArray
                    plistStorageManager.setObject(authObject1, forKey: "\(StaticContentFile.getId())", inFile: .authRequest)
                    return
                }
            }
        }
    }
    
    static func saveAuthRequest(_ result: AuthorizeRequest) {
        
        var dict =  [String: Any]()
        
        if let authObject = plistStorageManager.objectForKey("\(StaticContentFile.getId())", inFile: .authRequest) as? [String: Any], let array =  authObject["authRequest"] as? [[String: Any]] {
            
            var authArray = array
            var authObject1 = authObject
            
            if StaticContentFile.isDoctorLogIn() {
            
                for auth in result.authRequest {
                    
                    authArray.append(auth.modelToDict())
                }
            } else {
            
                for auth in result.authRequest {
                    
                    authArray.append(auth.modelToDictForParent())
                }
            }
            
            authObject1["data"] = authArray
            dict = authObject
            
        } else {
            
            if StaticContentFile.isDoctorLogIn() {
                
                dict =  result.modelToDict()
            } else {
                
                dict =  result.modelToDictForParent()
            }
        }
        
        plistStorageManager.setObject(dict, forKey: "\(StaticContentFile.getId())", inFile: .authRequest)
    }
    
    static func getAuthRequest() -> AuthorizeRequest? {
        
        if let authObject = plistStorageManager.objectForKey("\(StaticContentFile.getId())", inFile: .authRequest) as? [String: Any] {
            
            do {
                
                let jsonData = try JSONSerialization.data(withJSONObject: authObject, options: .prettyPrinted)
                if let jsonString = String.init(data: jsonData, encoding: .utf8),
                    let result = Mapper<AuthorizeRequest>().map(JSONString: jsonString) {
                    
                    return result
                }
            } catch {
                
                print(error.localizedDescription)
                return nil
            }
        }
        
        return nil
    }
}

//MARK:- save/get messages

extension StaticContentFile {
    
    static func saveMessage(_ message: RecentMessages, channelDetail: ChannelDetail) {
        
        var dict = [String: Any]()
        
        if let messageObject = plistStorageManager.objectForKey("\(channelDetail.channel_id)", inFile: .message) as? [String: Any],
            let obj = messageObject["\(channelDetail.channel_id)"] as? [String: Any],
            let messagesList = obj["recent_message"] as? [[String: Any]] {
            
            var messageObject1 = obj
            var list = messagesList
            
            if message.message_id >= channelDetail.lastMsgId {
                
                for (index, item) in list.enumerated() {
                    
                    if let id = item["message_id"] as? Int ,
                        id == message.message_id {
                        
                        list.remove(at: index)
                        
                        break
                    }
                }}
            
            list.append(message.modelToDict())
            messageObject1["recent_message"] = list
            messageObject1["unread_count"] = 0
            messageObject1["lastMsgId"] = message.message_id
            dict["\(channelDetail.channel_id)"] = messageObject1
            
            plistStorageManager.setObject(dict, forKey: "\(channelDetail.channel_id)", inFile: .message)
        }
    }
    
    static func updateChannelDetail(_ detail: ChannelDetail) {
    
        var dict =  [String: Any]()
        
        if let messageObject = plistStorageManager.objectForKey("\(detail.channel_id)", inFile: .message) as? [String: Any],
            
            let obj = messageObject["\(detail.channel_id)"] as? [String: Any] {
            
            var channelObject = obj
            channelObject["auth_status"] = detail.auth_status
            dict["\(detail.channel_id)"] = channelObject
            
             plistStorageManager.setObject(dict as Any , forKey: "\(detail.channel_id)", inFile: .message)
        }
    }
    
    static func getChannelDetail(_ detail: ChannelDetail) -> ChannelDetail? {
        
        if let messageObject = plistStorageManager.objectForKey("\(detail.channel_id)", inFile: .message) as? [String: Any],
            let obj = messageObject["\(detail.channel_id)"] as? [String: Any] {
            
             
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    if let jsonString = String.init(data: jsonData, encoding: .utf8),
                        let result = Mapper<ChannelDetail>().map(JSONString: jsonString) {
                        
                        return result
                    }} catch {}
            
            return nil
        }
        
         return nil
    }
    
    static func saveMessage(_ detail: ChannelDetail) {
        
        var dict =  [String: Any]()
        
        if let messageObject = plistStorageManager.objectForKey("\(detail.channel_id)", inFile: .message) as? [String: Any],
            let obj = messageObject["\(detail.channel_id)"] as? [String: Any] {
            
            var channelObject = obj
            
            if let msgs = obj["recent_message"] as? [[String: Any]] {
                
                var list = msgs
                
                for (i,msg) in msgs.enumerated() {
                
                    if let id = msg["channel_id"] as? Int, let lastId = msg["lastMsgId"] as? Int,  id == -1 || id > lastId  {
                      
                        list.remove(at: i)
                    }
                }
                
                for message in detail.recent_message {
                    
                    list.append(message.modelToDict())
                }
                
                channelObject["recent_message"] = list
                
                if let unreadCount = channelObject["unread_count"] as? Int {
                    
                    channelObject["unread_count"] = unreadCount + detail.unread_count
                }
                
                dict["\(detail.channel_id)"] = channelObject
            } else {
                
                dict["\(detail.channel_id)"] =  detail.modelToDict()
            }
            
        } else {
            
            dict["\(detail.channel_id)"] =  detail.modelToDict()
        }
        
        plistStorageManager.setObject(dict as Any , forKey: "\(detail.channel_id)", inFile: .message)
    }
    
    static func getChannel() -> [ChannelDetail] {
        
        var array = [ChannelDetail]()
        
        if let keys = plistStorageManager.allKeysInPlistFile(.message) {
            
            for key in keys {
                
                if let object = plistStorageManager.objectForKey("\(key)", inFile: .message) as? [String: Any],
                    let obj = object["\(key)"] as? [String: Any] {
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        if let jsonString = String.init(data: jsonData, encoding: .utf8),
                            let result = Mapper<ChannelDetail>().map(JSONString: jsonString) {
                            
                            array.append(result)
                        }} catch {}
                }}}
        return array
    }
}
