//
//  CustomNavigationBar.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class CustomNavigationBar: UIView {
    
    fileprivate var backButton  : UIButton!
    fileprivate var titleLabel  : UILabel!
    
    init() {
        
        super.init(frame: CGRect.zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setTitle(_ title: String, backButtonImageName name: String, showBackButton: Bool = true) {
        
        titleLabel.text = title
        backButton.setImage(UIImage(named: name), for: .normal)
        
        backButton.isHidden = !showBackButton
    }
    
    fileprivate func setup() {
        
        self.backgroundColor = UIColor.colorWithHex(0x3CCACC)
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        
        AutoLayoutHelper.addHorizontalAlignConstraintToView(titleLabel, withCenterOffset: 0)
        AutoLayoutHelper.addVerticalAlignConstraintToView(titleLabel, withCenterOffset: 0)
        
        backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)
        
        AutoLayoutHelper.addLeadingSpaceConstraintToView(backButton, leadingSpace: 15)
        AutoLayoutHelper.addTopSpaceConstraintToView(backButton, topSpace: 0)
        AutoLayoutHelper.addBottomSpaceConstraintToView(backButton, bottomSpace: 0)
        AutoLayoutHelper.addWidthConstraintToView(backButton, value: 45)
    }
}
