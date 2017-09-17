//
//  Extensions.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

extension String {
    
    func relaceCharacter() -> String {
        
        return self.replacingOccurrences(of: "'", with: "''")
    }
}

extension UIView {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: 25, y: self.frame.size.height/2, width: StaticContentFile.screenWidth - 50, height: 45))
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
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.backgroundColor = UIColor.white
        activityIndicator.color = UIColor.colorWithHex(0x3eb1d6)
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
        
        var timeAgo = ""
        
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        f.timeZone = .current
        
        let endDateStr = f.string(from: Date())
        
        if let endDate = f.date(from: endDateStr),
            let startDate = f.date(from: dateStr) {
            
            if startDate.isToday() {
                
                let t = endDate.timeIntervalSince(startDate)
                let formt = DateComponentsFormatter()
                formt.unitsStyle = .short
                formt.allowedUnits = [.second, .hour,.minute]
                let timeStr = formt.string(from: t)
                
                if let timeStrs = timeStr?.components(separatedBy: ", "), timeStrs.count > 0 {
                    
                    timeAgo = timeStrs[0] + " ago"
                }
            } else if let startDate = f.date(from: dateStr) {
                
                f.dateFormat = "dd/MM/yyyy hh:mm a"
                timeAgo = f.string(from: startDate)
            }
        }
        
        return timeAgo
    }
    
    func isToday () -> Bool {
        
        let diff = self.calendarDaysDifferenceFromToday()
        
        return diff == 0
    }
    
    func calendarDaysDifferenceFromToday () -> Int {
        
        return calendarDaysDifferenceSinceDate(Date())
    }
    
    func calendarDaysDifferenceSinceDate (_ date: Date) -> Int {
        
        return interval(ofComponent: .day, fromDate: date)
    }
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}

