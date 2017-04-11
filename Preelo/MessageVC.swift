//
//  MessageVC.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class MessageVC: UIViewController {

    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet fileprivate weak var messagesButton       : UIButton!
    @IBOutlet fileprivate weak var authorizationRequest : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       customNavigationBar.setTitle("Welcome Doctor", backButtonImageName: "Menu")
        messagesButton.isSelected = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
}
}
