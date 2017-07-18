//
//  FeedBackSupportVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 13/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class FeedBackSupportVC: UIViewController {
    
    
    @IBOutlet weak fileprivate var customNavigationBar: CustomNavigationBar!
    
    @IBOutlet fileprivate weak var sendButton: UIButton!
    @IBOutlet fileprivate weak var subject: FloatingTextField!
    @IBOutlet fileprivate weak var message: FloatingTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
    
    
    
    
    }
  
    
    
    
    
    
    fileprivate func setup(){
        
        StaticContentFile.setButtonFont(sendButton)
        customNavigationBar.setTitle("Feedback Support")
        customNavigationBar.delegate = self
    }
}









extension FeedBackSupportVC:CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        
        self.navigationController?.popViewController(animated: true)
    }
}




