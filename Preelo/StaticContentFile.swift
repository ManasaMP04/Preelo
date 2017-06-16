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
    
    static func setButtonFont(_ button: UIButton, backgroundColorNeeed: Bool = true, borderNeeded: Bool = true) {
        
        button.backgroundColor = backgroundColorNeeed ? UIColor.colorWithHex(0x3DB0BB) : UIColor.clear
        
        button.titleLabel?.font = UIFont(name: "Ubuntu-Bold", size: 12)!
        button.titleLabel?.textColor = UIColor.colorWithHex(0x3DB0BB)
        
        if borderNeeded {
            
            button.layer.borderColor = UIColor.colorWithHex(0x3DB0BB).cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = button.frame.size.width / 14
        }
        
        if backgroundColorNeeed {
            
            button.addShadowWithColor(UIColor.black, offset: CGSize(width: 0, height: 4), opacity: 0.4, radius: 5)
            button.titleLabel?.textColor = UIColor.white
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
        StaticContentFile.deleteMessagePlist()
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
            
            for auth in result.authRequest {
                
                authArray.append(auth.modelToDict())
            }
            
            authObject1["data"] = authArray
            dict = authObject
            
        } else {
            
            dict =  result.modelToDict()
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
    
    static func saveMessage(_ message: RecentMessages, id: Int, lastMessageId: Int = 0, removeArray: Bool = false) {
        
        var dict = [String: Any]()
        
        if let messageObject = plistStorageManager.objectForKey("\(id)", inFile: .message) as? [String: Any],
            let messageList =  messageObject["\(id)"] as? [String: Any],
            let messages = messageList["recent_message"] as? [[String: Any]] {
            
            var messageObject1 = messageList
            var list = messages
            
            if removeArray {
                
                for (index, item) in messages.enumerated() {
                    
                    if let id = item["message_id"] as? Int ,
                        id == message.message_id {
                        
                        list.removeLast(messages.count - index)
                    }
                }
            }
            
            list.append(message.modelToDict())
            messageObject1["recent_message"] = list
            messageObject1["unread_count"] = 0
            messageObject1["lastMsgId"] = lastMessageId
            dict["\(id)"] = messageObject1
            
        } else {
            
            dict["\(id)"] =  message.modelToDict()
        }
        
        plistStorageManager.setObject(dict, forKey: "\(id)", inFile: .message)
    }
    
    static func saveMessage(_ detail: ChannelDetail) {
        
        var dict =  [String: Any]()
        let id = StaticContentFile.isDoctorLogIn() ? detail.parentId : detail.doctorId
        
        if let messageObject = plistStorageManager.objectForKey("\(id)", inFile: .message) as? [String: Any],
            let msgDetail =  messageObject["\(id)"] as? [String: Any] {
            
            if let messages = msgDetail["recent_message"] as? [[String: Any]] {
                
                var msgList = msgDetail
                var list = messages
                
                for message in detail.recent_message {
                    
                    list.append(message.modelToDict())
                }
                
                msgList["recent_message"] = list
                msgList["unread_count"] = detail.unread_count
                dict["\(id)"] = msgList
            } else {
                
                dict["\(id)"] =  detail.modelToDict()
            }
            
        } else {
            
            dict["\(id)"] =  detail.modelToDict()
        }
        
        plistStorageManager.setObject(dict as Any , forKey: "\(id)", inFile: .message)
    }
    
    static func getChannel() -> [ChannelDetail] {
        
        var array = [ChannelDetail]()
        
        if let keys = plistStorageManager.allKeysInPlistFile(.message) {
            
            for key in keys {
                
                if let object = plistStorageManager.objectForKey("\(key)", inFile: .message) as? [String: Any], let obj = object["\(key)"]  {
                    
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
