//
//  AutoLayoutHelper.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class AutoLayoutHelper: NSObject {
    
    @discardableResult
    static func addSizeRatioConstraintToView(_ view: UIView, ratio: CGFloat) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .height,
                                            multiplier: ratio,
                                            constant: 0)
        
        view.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addLeadingSpaceConstraintToView(_ view: UIView, leadingSpace space: CGFloat, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .leading,
                                            relatedBy: relation,
                                            toItem: view.superview,
                                            attribute: .leading,
                                            multiplier: 1,
                                            constant: space)
        
        view.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addTrailingSpaceConstraintToView(_ view: UIView, trailingSpace space: CGFloat, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .trailing,
                                            relatedBy: relation,
                                            toItem: view.superview,
                                            attribute: .trailing,
                                            multiplier: 1,
                                            constant: -space)
        
        view.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addTopSpaceConstraintToView(_ view: UIView, topSpace space: CGFloat, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .top,
                                            relatedBy: relation,
                                            toItem: view.superview,
                                            attribute: .top,
                                            multiplier: 1,
                                            constant: space)
        
        view.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addVerticalSpaceConstraintBetweenViews(_ topView: UIView, bottomView: UIView,   verticalSpace  space: CGFloat, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: bottomView,
                                            attribute: .top,
                                            relatedBy: relation,
                                            toItem: topView,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: space)
        
        bottomView.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addHorizontalSpaceConstraintBetweenViews(_ leftView: UIView, rightView: UIView,   horizontalSpace  space: CGFloat, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: rightView,
                                            attribute: .left,
                                            relatedBy: relation,
                                            toItem: leftView,
                                            attribute: .right,
                                            multiplier: 1,
                                            constant: space)
        
        rightView.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addBottomSpaceConstraintToView(_ view: UIView, bottomSpace space: CGFloat, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .bottom,
                                            relatedBy: relation,
                                            toItem: view.superview,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: space)
        
        view.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addLeftEdgeAlignConstraintToView(_ view: UIView) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: view.superview,
                                            attribute: .left,
                                            multiplier: 1,
                                            constant: 0)
        
        view.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addRightEdgeAlignConstraintToView(_ view: UIView) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .right,
                                            relatedBy: .equal,
                                            toItem: view.superview,
                                            attribute: .right,
                                            multiplier: 1,
                                            constant: 0)
        
        view.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addPercentageOfParentWidthConstraintToView(_ view: UIView, withPercentage percentage: CGFloat) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: view.superview,
                                            attribute: .width,
                                            multiplier: percentage,
                                            constant: 0)
        
        view.superview!.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addConstraintToView(_ view: UIView, withAttribute attribute: NSLayoutAttribute, relativeToSuperviewAttribute parentAttribute: NSLayoutAttribute, withPecentage multiplier: CGFloat) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: view.superview,
                                            attribute: parentAttribute,
                                            multiplier: multiplier,
                                            constant: 0)
        
        view.superview!.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addConstraintToView(_ view: UIView, withAttribute attribute: NSLayoutAttribute, relativeToSiblingView siblingView: UIView, siblingAttribute: NSLayoutAttribute, withPecentage multiplier: CGFloat, inSuperView superview: UIView) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: siblingView,
                                            attribute: siblingAttribute,
                                            multiplier: multiplier,
                                            constant: 0)
        
        superview.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addPercentageOfParentTrailingSpaceConstraintToView(_ view: UIView, withPercentage percentage: CGFloat) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: view.superview!,
                                            attribute: .trailing,
                                            multiplier: percentage,
                                            constant: 0)
        
        view.superview!.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addPercentageOfParentBottomSpaceConstraintToView(_ view: UIView, withPercentage percentage: CGFloat) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view.superview!,
                                            attribute: .bottom,
                                            multiplier: percentage,
                                            constant: 0)
        
        view.superview!.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func alignTopsOfViews(_ views : [UIView], inSuperview superview: UIView) {
        
        if views.count > 1 {
            
            for i in 0 ..< (views.count - 1) {
                
                let constraint = NSLayoutConstraint(item: views[i],
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: views[i+1],
                                                    attribute: .top,
                                                    multiplier: 1,
                                                    constant: 0)
                
                superview.addConstraint(constraint)
            }
        }
    }
    
    @discardableResult
    static func verticallySpaceViews(_ views: [UIView], inSuperView superview: UIView, withSpace space: CGFloat, priority : UILayoutPriority = UILayoutPriorityRequired) {
        
        if views.count > 1 {
            
            for i in 0 ..< (views.count - 1) {
                
                let constraint = NSLayoutConstraint(item: views[i+1],
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: views[i],
                                                    attribute: .bottom,
                                                    multiplier: 1,
                                                    constant: space)
                
                constraint.priority = priority
                
                superview.addConstraint(constraint)
            }
        }
    }
    
    @discardableResult
    static func addHorizontalAlignConstraintToView(_ view: UIView, withCenterOffset offset: CGFloat) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: view.superview, attribute: .centerX, multiplier: 1, constant: offset)
        
        view.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addVerticalAlignConstraintToView(_ view: UIView, withCenterOffset offset: CGFloat) -> NSLayoutConstraint {
        
        return addVerticalAlignConstraintToView(view, withCenterOffset: offset, priority: UILayoutPriorityRequired)
    }
    
    @discardableResult
    static func addVerticalAlignConstraintToView(_ view: UIView, withCenterOffset offset: CGFloat, priority:UILayoutPriority) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: view.superview, attribute: .centerY, multiplier: 1, constant: offset)
        
        constraint.priority = priority
        
        view.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addWidthConstraintToView(_ view: UIView, relation: NSLayoutRelation = .equal, value: CGFloat, priority:UILayoutPriority=UILayoutPriorityRequired) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
        
        constraint.priority = priority
        
        view.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult
    static func addHeightConstraintToView(_ view: UIView, relation: NSLayoutRelation = .equal, value: CGFloat, priority:UILayoutPriority=UILayoutPriorityRequired) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
        
        constraint.priority = priority
        
        view.addConstraint(constraint)
        
        return constraint
    }
}
