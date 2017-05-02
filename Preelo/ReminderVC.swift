//
//  ReminderVC.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class ReminderVC: UIViewController {

    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        customNavigationBar.setTitle("Schedule", backButtonImageName: "Back")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        if let tab = self.parent as? TabBarVC {
            
            tab.changeTheItem()
        }
    }
}
