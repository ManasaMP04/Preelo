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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationView.addShadowWithColor(UIColor.lightGray)
        notificationView.layer.cornerRadius = 5
        notificationView.layer.borderWidth = 0.2
        notificationView.layer.borderColor = UIColor.lightGray.cgColor
        customeNavigation.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setTitle(_ title: String, description: NSAttributedString, notificationTitle: String) {
        
        customeNavigation.setTitle(title)
        self.notificationTitle.text = notificationTitle
        notificationDetail.attributedText = description
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        delegate?.tappedDoneButton(self)
    }
}

extension AlertVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}
