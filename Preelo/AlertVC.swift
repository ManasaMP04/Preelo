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
    
    weak var delegate : AlertVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setTitle(_ title: String, description: NSAttributedString) {
        
        notificationTitle.text = title
        notificationDetail.attributedText = description
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        delegate?.tappedDoneButton(self)
    }
}
