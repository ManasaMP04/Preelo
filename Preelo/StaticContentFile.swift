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
    
    static let dbManager       = DBManager.init(fileName: "chat.db")
    
    static let channelTableName       = "channel"
    static let messageTableName       = "message"
    static var isForChannel = true
    
    static func createDB() {
        
        //  dbManager?.delegate = self
        
        let queryString = String(format: "CREATE TABLE IF NOT EXISTS \(channelTableName) (channel_id INTEGER,relationship TEXT, patientname TEXT, doctorname TEXT, parentname TEXT,doctor_initials TEXT, unread_count  INTEGER, doctorId  INTEGER,parentId  INTEGER,patientId  INTEGER, auth_status TEXT, doctor_user_id  INTEGER,lastMsgId  INTEGER, chatTitle TEXT,chatLabelTitle TEXT)")
        
        let queryString1 = String(format: "CREATE TABLE IF NOT EXISTS \(messageTableName) (channel_id INTEGER, message_type TEXT, message_text  TEXT, message_date TEXT,image_url TEXT, thumb_Url TEXT, message_id  INTEGER,senderId TEXT)")
        
        dbManager?.createTable(forQuery: queryString)
        dbManager?.createTable(forQuery: queryString1)
    }
    
    static func clearDbTableWithId(_ id: Int? = nil) {
        
        if let id1 = id {
            
            let queryString = String(format: "DELETE FROM \(messageTableName) WHERE channel_id = \(id1)")
            dbManager?.deleteRow(forQuery: queryString)
        } else {
            
            let queryString = String(format: "DELETE FROM \(messageTableName)")
            let queryString1 = String(format: "DELETE FROM \(channelTableName)")
            dbManager?.deleteRow(forQuery: queryString)
            dbManager?.deleteRow(forQuery: queryString1)
        }
    }
    
    static func insertRowIntoDB(_ recentMessage: RecentMessages? = nil, channelDetail: ChannelDetail) {
        
        let sl = "SELECT COUNT(*) FROM channel where channel_id = \(channelDetail.channel_id)"
        
        if let count = dbManager?.getNumberOfRecord(sl), count > 0 {
            
            if let message = recentMessage {
                
                let queryString1 = String(format: "DELETE FROM \(messageTableName) WHERE message_id = \(message.message_id) AND channel_id = \(channelDetail.channel_id)")
                dbManager?.deleteRow(forQuery: queryString1)
                
                let queryString = String(format: "INSERT INTO \(messageTableName)(channel_id, message_type, message_text, message_date, image_url, thumb_Url, message_id, senderId) VALUES(?,?,?,?,?,?,?,?)", channelDetail.channel_id, message.message_type, message.message_text, message.message_date, message.image_url, message.thumb_Url, message.message_id, message.senderId)
                
                dbManager?.saveDataToDB(forQuery: queryString)
            } else {
            
            let queryString = String(format: "INSERT INTO \(channelTableName)(channel_id, relationship, patientname, doctorname,parentname, doctor_initials,unread_count, doctorId, parentId, patientId, auth_status, doctor_user_id, lastMsgId, chatTitle, chatLabelTitle) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", channelDetail.channel_id, channelDetail.relationship, channelDetail.patientname, channelDetail.doctorname, channelDetail.parentname, channelDetail.doctor_initials, channelDetail.unread_count, channelDetail.doctorId, channelDetail.parentId, channelDetail.patientId, channelDetail.auth_status, channelDetail.doctor_user_id, channelDetail.lastMsgId, channelDetail.chatTitle, channelDetail.chatLabelTitle)
            
            dbManager?.saveDataToDB(forQuery: queryString)
            }
        } else if channelDetail.recent_message.count > 0 {
            
            let message = channelDetail.recent_message[channelDetail.recent_message.count - 1]
            let queryString = String(format: "INSERT INTO \(messageTableName)(channel_id, message_type, message_text, message_date, image_url, thumb_Url, message_id, senderId) VALUES(?,?,?,?,?,?,?,?)", channelDetail.channel_id, message.message_type, message.message_text, message.message_date, message.image_url, message.thumb_Url, message.message_id, message.senderId)
            
            dbManager?.saveDataToDB(forQuery: queryString)
            
            let queryString1 = String(format: "INSERT INTO \(channelTableName)(channel_id, relationship, patientname, doctorname,parentname, doctor_initials,unread_count, doctorId, parentId, patientId, auth_status, doctor_user_id, lastMsgId, chatTitle, chatLabelTitle) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", channelDetail.channel_id, channelDetail.relationship, channelDetail.patientname, channelDetail.doctorname, channelDetail.parentname, channelDetail.doctor_initials, channelDetail.unread_count, channelDetail.doctorId, channelDetail.parentId, channelDetail.patientId, channelDetail.auth_status, channelDetail.doctor_user_id, channelDetail.lastMsgId, channelDetail.chatTitle, channelDetail.chatLabelTitle)
            dbManager?.saveDataToDB(forQuery: queryString1)
        }
    }
    
    static func updateChannelDetail(_ channelDetail: ChannelDetail, isAuthStatus: Bool) {
        
        if isAuthStatus {
            let queryString = String(format: "update \(channelTableName) set auth_status ='\(channelDetail.auth_status)' where channel_id = \(channelDetail.channel_id)")
            
            dbManager?.update(queryString)
        }else {
            
            let queryString = String(format: "update \(channelTableName) set lastMsgId ='\(channelDetail.lastMsgId)', unread_count = \(0)  where channel_id = \(channelDetail.channel_id)")
            
            dbManager?.update(queryString)
        }
    }
}


//MARK:- all button fonts

extension StaticContentFile {
    
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
        StaticContentFile.clearDbTableWithId()
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
                
                if let patientId = element["patientid"] as? Int,
                    let parentId = element["parentid"] as? Int,
                    let drId     = element["doctorid"] as? Int ,
                    patientId == result.patientid, parentId == result.parentid, drId == result.doctorid  {
                    
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
