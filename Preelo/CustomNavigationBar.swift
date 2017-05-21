//
//  CustomNavigationBar.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol CustomNavigationBarDelegate: class {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar)
}

class CustomNavigationBar: UIView {
    
    fileprivate var backButton  : UIButton!
    fileprivate var titleLabel  : UILabel!
    
    weak var delegate : CustomNavigationBarDelegate?
    
    init() {
        
        super.init(frame: CGRect.zero)
        
        setup()
    }
    
    override open class var layerClass: AnyClass {
        get{
            return CAGradientLayer.classForCoder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setTitle(_ title: String, backButtonImageName name: String = "Back", showBackButton: Bool = true) {
        
        titleLabel.text = title
        backButton.setImage(UIImage(named: name), for: .normal)
        
        backButton.isHidden = !showBackButton
    }
    
    @objc fileprivate func backButtonTapped(_ sender: Any) {
        
        delegate?.tappedBackButtonFromVC(self)
    }
    
    fileprivate func setup() {
        
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.colorWithHex(0x43BACB).cgColor, UIColor.colorWithHex(0x42C6CB).cgColor]
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Ubuntu-Medium", size: 15)
        
        AutoLayoutHelper.addHorizontalAlignConstraintToView(titleLabel, withCenterOffset: 0)
       AutoLayoutHelper.addTopSpaceConstraintToView(titleLabel, topSpace: 25)
        
        backButton = UIButton()
        backButton.addTarget(self, action: #selector(backButtonTapped(_ :)), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)
        
        AutoLayoutHelper.addLeadingSpaceConstraintToView(backButton, leadingSpace: 0)
        AutoLayoutHelper.addVerticalAlignConstraintToView(backButton, withCenterOffset: 5)
        AutoLayoutHelper.addHeightConstraintToView(backButton, value: 45)
        AutoLayoutHelper.addWidthConstraintToView(backButton, value: 45)
    }
}
