//
//  Extensions.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

extension UIView {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: 50, y: self.frame.size.height/2, width: self.frame.size.width - 100, height: 45))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.numberOfLines = 0
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.systemFont(ofSize: 12)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func addShadowWithColor(_ color: UIColor, offset: CGSize=CGSize(width: 1, height: 1), opacity: Float=0.20, radius: CGFloat=3) {
        
        self.layer.shadowColor      = color.cgColor
        self.layer.shadowOffset     = offset
        self.layer.shadowOpacity    = opacity
        self.layer.shadowRadius     = radius
        self.layer.masksToBounds    = false
    }
    
    @IBInspectable var shadowColor: UIColor? {
        set {
            layer.shadowColor = newValue!.cgColor
        }
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGPoint {
        set {
            layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
        }
        get {
            return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height)
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
}

//MARK:- UINavigationController

extension UINavigationController {
    
    func viewControllerWithClass(_ aClass: AnyClass) -> UIViewController? {
        
        for vc in self.viewControllers {
            
            if vc.isMember(of: aClass) {
                
                return vc
            }
        }
        
        return nil
    }
}

extension UIColor {
    
    static func colorWithHex (_ hex : Int, alpha: CGFloat=1.0) -> UIColor {
        
        let cmp = (
            r : CGFloat(((hex >> 16) & 0xFF))/255.0,
            g : CGFloat(((hex >> 08) & 0xFF))/255.0,
            b : CGFloat(((hex >> 00) & 0xFF))/255.0
        )
        
        return UIColor(red: cmp.r, green: cmp.g, blue: cmp.b, alpha: alpha)
    }
}

extension UIActivityIndicatorView {
    
    static func activityIndicatorToView(_ view: UIView) -> UIActivityIndicatorView {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.backgroundColor = UIColor.lightGray
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        AutoLayoutHelper.addHorizontalAlignConstraintToView(activityIndicator, withCenterOffset: 0)
        AutoLayoutHelper.addVerticalAlignConstraintToView(activityIndicator, withCenterOffset: 0)
        AutoLayoutHelper.addWidthConstraintToView(activityIndicator, value: 60)
        AutoLayoutHelper.addHeightConstraintToView(activityIndicator, value: 60)
        
        return activityIndicator
    }
}

//MARK:- NSDate

extension Date {
    
    func stringWithDateFormat (_ format: String, locale : Locale = Locale(identifier: "en_US_POSIX")) -> String {
        
        let df          = DateFormatter()
        df.locale       = locale
        df.dateFormat   = format
        
        return df.string(from: self)
    }
    
    static func dateWithFormat(_ format : String, fromString string: String) -> Date? {
        
        let df          = DateFormatter()
        df.locale       = Locale(identifier: "en_US_POSIX")
        df.dateFormat   = format
        
        return df.date(from: string)
    }
    
    static func dateDiff(dateStr:String) -> String {
        
        let f = DateFormatter()
        f.timeZone = NSTimeZone.local
        f.dateFormat = "yyyy-M-dd'T'HH:mm:ss.A"
        
        let now = f.string(from: Date())
        let startDate = f.date(from: dateStr)
        let endDate = f.date(from: now)
        
        var timeAgo = ""
        
        if let str = startDate, let end = endDate {
            
            let dateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second, .weekOfMonth, .month, .year], from: str, to: end)
            
            if let weeks = dateComponents.weekOfMonth,
                let month = dateComponents.month,
                let year = dateComponents.year,
                let days = dateComponents.day,
                let hours = dateComponents.hour,
                let min = dateComponents.minute,
                let sec = dateComponents.second {
                
                if (sec > 0){
                    if (sec > 1) {
                        timeAgo = "\(sec) Seconds Ago"
                    } else {
                        timeAgo = "\(sec) Second Ago"
                    }
                }
                
                if (min > 0){
                    if (min > 1) {
                        timeAgo = "\(min) Minutes Ago"
                    } else {
                        timeAgo = "\(min) Minute Ago"
                    }
                }
                
                if(hours > 0){
                    if (hours > 1) {
                        timeAgo = "\(hours) Hours Ago"
                    } else {
                        timeAgo = "\(hours) Hour Ago"
                    }
                }
                
                if (days > 0) {
                    if (days > 1) {
                        timeAgo = "\(days) Days Ago"
                    } else {
                        timeAgo = "\(days) Day Ago"
                    }
                }
                
                if(weeks > 0){
                    if (weeks > 1) {
                        timeAgo = "\(weeks) Weeks Ago"
                    } else {
                        timeAgo = "\(weeks) Week Ago"
                    }
                }
                
                if(month > 0){
                    if (month > 1) {
                        timeAgo = "\(year) Months Ago"
                    } else {
                        timeAgo = "\(year) Month Ago"
                    }
                }
                
                if(year > 0){
                    if (year > 1) {
                        timeAgo = "\(year) Years Ago"
                    } else {
                        timeAgo = "\(year) Year Ago"
                    }
                }
            }
        }
        
        return timeAgo
    }
}

