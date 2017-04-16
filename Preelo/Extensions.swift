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
        
        let toastLabel = UILabel(frame: CGRect(x: 50, y: self.frame.size.height/2, width: self.frame.size.width - 100, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
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
