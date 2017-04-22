//
//  TextValidator.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

enum TextInputType {
    
    case generic
    case name
    case password
    case email
    case mobile
}

class TextValidator: NSObject {

   
    enum PermissionRegex: String {
        
        case Email          = "[a-zA-Z0-9_@.-]*"
        case Numbers        = "[0-9]*"
        case Name           = "([a-zA-Z][ ]{0,1})*"
        case Generic        = "^(?!\\s\\s*$).*"
        case Password       = "[^\\s]*"
    }
    
    enum ValidationRegex: String {
        
        case Email         = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$"
        case Mobile        = "^[0-9]{10}$"
        case Name          = "^[a-zA-Z ]*[a-zA-Z]+[a-zA-Z ]*$"
        case Generic       = "^(?!\\s*$).+"
        case Password      = "^[A-Z0-9a-z]{3,15}$"
    }
    
    struct Rule {
        
        let limit               : Int
        let regex               : String
        let subregex            : String
        let emptyMessage        : String
        let validationMessage   : String
    }
    
    
    fileprivate let inputType   : TextInputType
    fileprivate var rule        : Rule!
    
    init(inputType: TextInputType) {
        
        self.inputType = inputType
        
        super.init()
        
        buildRules()
    }
    
    fileprivate func buildRules() {
        
        var limit = 0
        var regex: String, subregex: String, emptyMessage: String, validationMessage: String
        
        switch self.inputType {
            
        case .generic:
            limit = 100
            regex = ValidationRegex.Generic.rawValue
            subregex = PermissionRegex.Generic.rawValue
            emptyMessage = NSLocalizedString("Input cannot be empty", comment:"Error message")
            validationMessage = NSLocalizedString("Enter a valid input", comment:"Validation message")
            break
            
        case .name:
            limit = 50
            regex = ValidationRegex.Name.rawValue
            subregex = PermissionRegex.Name.rawValue
            emptyMessage = NSLocalizedString("Name cannot be empty", comment:"Error message")
            validationMessage = NSLocalizedString("Enter a valid Name", comment:"Validation message")
            break
            
        case .email:
            limit = 100
            regex = ValidationRegex.Email.rawValue
            subregex = PermissionRegex.Email.rawValue
            emptyMessage = NSLocalizedString("Email cannot be empty", comment:"Error message")
            validationMessage = NSLocalizedString("Enter a valid Email", comment:"Validation message")
            break
            
        case .mobile:
            limit = 10
            regex = ValidationRegex.Mobile.rawValue
            subregex = PermissionRegex.Numbers.rawValue
            emptyMessage = NSLocalizedString("Mobile cannot be empty", comment:"Error message")
            validationMessage =  NSLocalizedString("Enter a 10-digit Mobile number", comment:"Validation message")
            break
        
        case .password:
            limit = 30
            regex = ValidationRegex.Password.rawValue
            subregex = PermissionRegex.Password.rawValue
            emptyMessage = NSLocalizedString("Password cannot be empty", comment:"Error message")
            validationMessage = NSLocalizedString("Enter your password", comment:"Validation message")
            break
        }
        
        self.rule = Rule(limit: limit, regex: regex, subregex: subregex, emptyMessage: emptyMessage, validationMessage: validationMessage)
    }
}

extension TextValidator {
    
    func allowChangeOfText(_ text: String?, byReplacingCharactersInRange range: NSRange, withString replacement: String) -> Bool {
        
        let originalText = (text ?? "") as NSString
        let newText = originalText.replacingCharacters(in: range, with: replacement) as NSString
        
        let limit = max(self.rule.limit, originalText.length)
        let regex = self.rule.subregex
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        let allowChange = newText.length <= limit && predicate.evaluate(with: newText)
        
        return allowChange
    }
    
    func isValidText (_ text: String?) -> Bool {
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", self.rule.regex)
        
        return predicate.evaluate(with: text)
    }
    
    func validationMessageForText(_ text: String?) -> String? {
        
        if isValidText(text) {
            
            return nil
            
        } else if text!.isEmpty {
            
            return self.rule.emptyMessage
            
        } else {
            
            return self.rule.validationMessage
        }
    }
}
