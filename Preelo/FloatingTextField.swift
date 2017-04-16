//
//  FloatingTextField.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class FloatingTextField: PreeloTextField {
    
    let animationDuration = 0.3
    var title = UILabel()
    
    // MARK:- Properties
    
    override var placeholder:String? {
        didSet {
            title.text = placeholder
            title.sizeToFit()
        }
    }
    
    override var attributedPlaceholder:NSAttributedString? {
        didSet {
            title.text = attributedPlaceholder?.string
            title.sizeToFit()
        }
    }
    
    var titleFont:UIFont? = UIFont.systemFont(ofSize: 12) {
        didSet {
            title.font = titleFont
            title.sizeToFit()
        }
    }
    
    @IBInspectable var hintYPadding:CGFloat = 0.0
    
    @IBInspectable var titleYPadding:CGFloat = 0.0 {
        didSet {
            var r = title.frame
            r.origin.y = titleYPadding
            title.frame = r
        }
    }
    
    @IBInspectable var titleTextColor  = UIColor(white: 0.4, alpha: 1.0) {
        didSet {
            if !isFirstResponder {
                title.textColor = titleTextColor
            }
        }
    }
    
    @IBInspectable var titleActiveTextColor = UIColor(white: 0.2, alpha: 1.0)  {
        didSet {
            if isFirstResponder {
                title.textColor = titleActiveTextColor
            }
        }
    }
    
    // MARK:- Init
    required init?(coder aDecoder:NSCoder) {
        
        super.init(coder:aDecoder)
        
        setup()
    }
    
    required init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    // MARK:- Overrides
    override func layoutSubviews() {
        super.layoutSubviews()
        setTitlePositionForTextAlignment()
        let isResp = isFirstResponder
        
        if isResp && !(self.isEmpty()) {
            title.textColor = titleActiveTextColor
        } else {
            title.textColor = titleTextColor
        }
        
        if self.isEmpty() {
            
            hideTitle(isResp)
        } else {
            
            showTitle(isResp)
        }
    }
    
    override func textRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.textRect(forBounds: bounds)
        if !self.isEmpty() && self.appearance != .label {
            var top = ceil(title.font.lineHeight + hintYPadding)
            top = min(top, maxTopInset())
            r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(top, 0.0, 0.0, 0.0))
        }
        return r.integral
    }
    
    override func editingRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.editingRect(forBounds: bounds)
        if !self.isEmpty() && self.appearance != .label  {
            var top = ceil(title.font.lineHeight + hintYPadding)
            top = min(top, maxTopInset())
            r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(top, 0.0, 0.0, 0.0))
        }
        return r.integral
    }
    
    override func appearLikeLabel(_ dismissKeyboard: Bool=true) {
        
        super.appearLikeLabel(dismissKeyboard)
        
        self.title.isHidden = true
    }
    
    override func appearLikeTextField() {
        
        super.appearLikeTextField()
        
        self.title.isHidden = false
    }
    
    // MARK:- Public Methods
    
    // MARK:- Private Methods
    fileprivate func setup() {
        
        title.alpha = 0.0
        title.font = titleFont
        title.textColor = titleTextColor
        if let str = placeholder {
            if !str.isEmpty {
                title.text = str
                title.sizeToFit()
            }
        }
        self.addSubview(title)
    }
    
    fileprivate func maxTopInset()->CGFloat {
        return max(0, floor(bounds.size.height - font!.lineHeight - 4.0))
    }
    
    fileprivate func setTitlePositionForTextAlignment() {
        let r = textRect(forBounds: bounds)
        var x = r.origin.x
        if textAlignment == NSTextAlignment.center {
            x = r.origin.x + (r.size.width * 0.5) - (title.frame.size.width * 0.5)
        } else if textAlignment == NSTextAlignment.right {
            x = r.origin.x + r.size.width - title.frame.size.width
        }
        title.frame = CGRect(x:x, y:title.frame.origin.y, width:title.frame.size.width, height:title.frame.size.height)
    }
    
    fileprivate func showTitle(_ animated:Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [.beginFromCurrentState, .curveEaseOut], animations:{
            
            self.title.alpha = 1.0
            var r = self.title.frame
            r.origin.y = self.titleYPadding
            self.title.frame = r
        }, completion:nil)
    }
    
    fileprivate func hideTitle(_ animated:Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [.beginFromCurrentState, .curveEaseIn], animations:{
            // Animation
            self.title.alpha = 0.0
            var r = self.title.frame
            r.origin.y = self.title.font.lineHeight + self.hintYPadding
            self.title.frame = r
        }, completion:nil)
    }
    
    fileprivate func isEmpty () -> Bool {
        
        return self.text == nil || self.text!.isEmpty
    }
}
