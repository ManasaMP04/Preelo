//
//  AlertVC.swift
//  Preelo
//
//  Created by Manasa MP on 12/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol AlertVCDelegate: class {
    
    func tappedDoneButton(_ alertVC: AlertVC)
}

class AlertVC: UIViewController {
    
    @IBOutlet fileprivate weak var notificationDetail   : UILabel!
    @IBOutlet fileprivate weak var notificationTitle    : UILabel!
    @IBOutlet fileprivate weak var customeNavigation    : CustomNavigationBar!
    @IBOutlet fileprivate weak var doneButton           : UIButton!
    @IBOutlet fileprivate weak var notificationView     : UIView!
    
    weak var delegate : AlertVCDelegate?
    
    fileprivate var titleValue = ""
    fileprivate var descriptionString: NSAttributedString?
    fileprivate var notificationString = ""
    fileprivate var isHideCustomeNavigation = false
    fileprivate var tabbarVC: TabBarVC?
    
    init (_ title: String, description: NSAttributedString, notificationTitle: String, isHideCustomeNavigation: Bool = false, navigation: UIViewController?) {
        
        self.titleValue = title
        self.descriptionString = description
        self.notificationString = notificationTitle
        self.isHideCustomeNavigation = isHideCustomeNavigation
        
        if let nav = navigation as? UINavigationController,
            let tab = nav.parent as? TabBarVC {
            
            tabbarVC = tab
        }
        
        super.init(nibName: "AlertVC", bundle: nil)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    fileprivate func setup() {
        
        notificationView.layer.cornerRadius = 5
        notificationView.layer.borderWidth = 0.2
        notificationView.layer.borderColor = UIColor.lightGray.cgColor
        StaticContentFile.setButtonFont(doneButton, backgroundColorNeeed: true)
        customeNavigation.delegate = self
        customeNavigation.setTitle(titleValue)
        self.notificationTitle.text = notificationString
        notificationDetail.attributedText = descriptionString
        self.customeNavigation.isHidden = isHideCustomeNavigation
        
        if let tab = tabbarVC {
        
            tab.tabBar.isHidden = true
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        if let tab = tabbarVC {
            
            tab.tabBar.isHidden = false
        }
        
        delegate?.tappedDoneButton(self)
    }
}

extension AlertVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}
