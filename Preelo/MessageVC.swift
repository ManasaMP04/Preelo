//
//  MessageVC.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class MessageVC: UIViewController {
    
    enum selection: Int {
    
        case message = 0
        case authentication
    }
    
    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet fileprivate weak var messagesButton       : UIButton!
    @IBOutlet fileprivate weak var authorizationRequest : UIButton!
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customNavigationBar.setTitle("Welcome Doctor", backButtonImageName: "Menu")
        customNavigationBar.delegate = self
        messagesButton.isSelected = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension MessageVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        if let slideOutVC = storyboard?.instantiateViewController(withIdentifier: "SlideOutVC") {
            navigationController?.pushViewController(slideOutVC, animated: true)
        }
    }
}
