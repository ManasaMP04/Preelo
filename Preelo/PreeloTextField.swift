//
//  PreeloTextField.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

@objc
protocol PreeloTextFieldDelegate : class {
    
    @objc optional func textFieldReturned(_ textField: PreeloTextField)
    
    @objc optional func textFieldBeganEditing(_ textField: PreeloTextField)
    
    @objc optional func textFieldEndedEditing(_ textField: PreeloTextField)
    
    @objc optional func textFieldEditingChanged(_ textField: PreeloTextField)
    
    @objc optional func textFieldDidBackspace(_ textField: PreeloTextField)
    
    @objc optional func textFieldShouldBeginEditing(_ textField: PreeloTextField) -> Bool
    
    @objc optional func textFieldWillClear(_ textField: PreeloTextField)
}

class PreeloTextField: UITextField {
    
    //MARK:- Public Properties
    
    weak var textFieldDelegate : PreeloTextFieldDelegate?
    
    enum RBPTextFieldAppearance {
        
        case textField
        case label
    }
    
    fileprivate(set) var appearance     : RBPTextFieldAppearance    = .textField
    fileprivate(set) var inputType      : TextInputType          = .generic
    
    //MARK:- Private Properties
    fileprivate var bottomBorder        = CALayer()
    fileprivate var defaultBorderColor  =  UIColor(white: 201/255, alpha: 1)
    var isCompleteBoarder = false
    
    fileprivate var validator       : TextValidator?
    
    //MARK:- Public APIs
    
    func setLeftViewIcon (_ icon : String) {
        
        let image = UIImage(named: icon)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height))
        imageView.image = image
        imageView.contentMode = .center
        
        self.leftView = imageView
        self.leftViewMode = .always
    }
    
    func appearLikeLabel (_ dismissKeyboard: Bool=true) {
        
        self.appearance = .label
        self.bottomBorder.backgroundColor = UIColor.clear.cgColor
        
        if dismissKeyboard {
            
            self.resignFirstResponder()
            self.isUserInteractionEnabled = false
        }
    }
    
    func appearLikeTextField () {
        
        self.appearance = .textField
        self.bottomBorder.backgroundColor = defaultBorderColor.cgColor
        self.isUserInteractionEnabled = true
    }
    
    func validateForInputType(_ inputType: TextInputType, andNotifyDelegate delegate: PreeloTextFieldDelegate?) {
        
        self.inputType = inputType
        
        validator               = TextValidator(inputType: inputType)
        self.delegate           = self
        self.textFieldDelegate  = delegate
    }
    
    func matchesRegex(_ regex: String?) -> Bool {
        
        let input = self.text ?? ""
        
        if let regex  = regex {
            
            let regex = regex.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            
            do {
                
                let _ = try NSRegularExpression(pattern: regex, options: [])
                
                let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                
                return predicate.evaluate(with: input)
                
            } catch _ as NSError {
                
                NSLog("This \(regex) regex was bad!")
            }
        }
        
        return input.characters.count > 0
    }
    
    func regexValidationMessage() -> String {
        
        if text!.isEmpty {
            
            return "Input cannot be empty"
            
        } else {
            
            return "Input is not Valid"
        }
    }
    
    func isValid () -> Bool {
        
        if self.validator != nil {
            
            return self.validator!.isValidText(self.text)
        }
        
        return false
    }
    
    func validationMessage () -> String? {
        
        return self.validator?.validationMessageForText(self.text)
    }
    
    func setBottomBorderHidden(_ hidden: Bool) {
        
        self.bottomBorder.isHidden = hidden
    }
    
    //MARK:- Init Methods
    
    required override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupDefaultAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setupDefaultAppearance()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.adjustBorder()
    }
    
    // MARK:- Events
    
    func editingBegan () {
        
        if self.appearance == .textField {
            
            bottomBorder.backgroundColor = UIColor.darkGray.cgColor
        }
    }
    
    func editingEnded () {
        
        if self.appearance == .textField {
            
            bottomBorder.backgroundColor = defaultBorderColor.cgColor
        }
    }
    
    func editingChanged () {
        
        self.textFieldDelegate?.textFieldEditingChanged?(self)
    }
    
    // MARK:- Left & Right View Management
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        
        return CGRect(x: 0, y: 0, width: 30, height: bounds.size.height)
    }
    
    override func clearButtonRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.clearButtonRect(forBounds: bounds)
        r.origin.x -= 10
        
        return r.integral
    }
    
    //MARK:- Private Functions
    
    fileprivate func adjustBorder () {
        
        if isCompleteBoarder {
            
            let borderWidth: CGFloat    = 0.5
            
            bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: borderWidth);
        } else {
            
            let borderWidth: CGFloat    = 0.5
            let offset: CGFloat         = 10
            
            bottomBorder.frame = CGRect(x: offset, y: self.frame.size.height - borderWidth, width: self.frame.size.width - 2*offset, height: borderWidth);
        }
    }
    
    fileprivate func setupDefaultAppearance () {
        
        self.borderStyle = UITextBorderStyle.none
        
        self.addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        
        self.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
        
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        bottomBorder.backgroundColor = defaultBorderColor.cgColor
        self.layer.addSublayer(bottomBorder)
        self.adjustBorder()
    }
    
    //MARK:- De-Init
    
    deinit {
        
        self.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
    }
}

extension PreeloTextField : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let shouldBegin = self.textFieldDelegate?.textFieldShouldBeginEditing?(self)
        
        return shouldBegin ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let change = self.validator?.allowChangeOfText(self.text, byReplacingCharactersInRange: range, withString: string) ?? false
        
        return change
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.textFieldDelegate?.textFieldReturned?(self)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.textFieldDelegate?.textFieldBeganEditing?(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.textFieldDelegate?.textFieldEndedEditing?(self)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        self.textFieldDelegate?.textFieldWillClear?(self)
        return true
    }
    
    override func deleteBackward() {
        
        super.deleteBackward()
        self.textFieldDelegate?.textFieldDidBackspace?(self)
    }
}


extension PreeloTextField {
    
    func configureKeyboardForInputType(_ inputType: TextInputType) {
        
        switch inputType {
            
        case .generic:
            self.keyboardType           = .default
            self.autocapitalizationType = .none
            self.autocorrectionType     = .no
            break
            
        case .name:
            self.keyboardType           = .default
            self.autocapitalizationType = .words
            self.autocorrectionType     = .no
            break
            
        case .email:
            self.keyboardType           = .emailAddress
            self.autocapitalizationType = .none
            self.autocorrectionType     = .no
            break
            
        case .mobile:
            self.keyboardType           = .phonePad
            break
            
        case .password:
            self.keyboardType           = .default
            self.autocapitalizationType = .none
            self.autocorrectionType     = .no
            break
        }
    }
}
