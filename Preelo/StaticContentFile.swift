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
    
    static let defaults = UserDefaults.standard
    static let screenBounds     = UIScreen.main.bounds
    static let screenWidth      = screenBounds.size.width
    static let screenHeight     = screenBounds.size.height
    
    static func setButtonFont(_ button: UIButton, backgroundColorNeeed: Bool = true) {
        
        button.backgroundColor = backgroundColorNeeed ? UIColor.colorWithHex(0x3DB0BB) : UIColor.clear
        
        button.titleLabel?.font = UIFont(name: "Ubuntu-Bold", size: 12)!
        
        button.layer.borderColor = UIColor.colorWithHex(0x3DB0BB).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = button.frame.size.width / 14
        
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
    
    static func getAuthRequest() -> AuthorizeRequest? {
        
        do {
            
            if let requests = defaults.value(forKey: "authRequest") {
                
                let jsonData = try JSONSerialization.data(withJSONObject: requests, options: .prettyPrinted)
                
                if let jsonString = String.init(data: jsonData, encoding: .utf8),
                    let result = Mapper<AuthorizeRequest>().map(JSONString: jsonString) {
                    
                    return result
                }
                
            }} catch { }
        
        return nil
    }
    
    static func getChannel() -> ChannelObject? {
        
        do {
            
            if let requests = defaults.value(forKey: "channel") {
                
                let jsonData = try JSONSerialization.data(withJSONObject: requests, options: .prettyPrinted)
                
                if let jsonString = String.init(data: jsonData, encoding: .utf8),
                    let result = Mapper<ChannelObject>().map(JSONString: jsonString) {
                    
                    return result
                }
                
            }} catch { }
        
        return nil
    }
    
    static func getId() -> Int {
        
        return defaults.integer(forKey: "id")
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func removeAllKeys() {
        
        defaults.removeObject(forKey: "isDoctorLogIn")
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "id")
    }
}
