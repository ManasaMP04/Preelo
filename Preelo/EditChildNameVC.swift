//
//  EditChildNameVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 14/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class EditChildNameVC: UIViewController {

    @IBOutlet weak var confirmChangeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var childrenFirstName: FloatingTextField!
    @IBOutlet weak var childrenLastName: FloatingTextField!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var customNavigation: CustomNavigationBar!
    
    
    fileprivate var scrollViewBottomInset : CGFloat! {
        
        didSet {
            
            var currentInset                = self.scrollView.contentInset
            currentInset.bottom             = scrollViewBottomInset
            self.scrollView.contentInset    = currentInset
        }
    }
    

    
    override func viewDidLoad() {
        
    super.viewDidLoad()

        // Do any additional setup after loading the view.
    self.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func gestureIsTapped(_ sender: Any) {
        
        view.endEditing(true)
    }



}

extension EditChildNameVC{
    fileprivate func setup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        customNavigation.setTitle("Edit Child Name")

        childrenFirstName.textFieldDelegate = self as? PreeloTextFieldDelegate
        childrenLastName.textFieldDelegate = self as? PreeloTextFieldDelegate
       // childrenFirstName.setLeftViewIcon("UserName")
       // childrenLastName.setLeftViewIcon("Password")
        StaticContentFile.setFontForTF(childrenFirstName, autoCaps: false)
        StaticContentFile.setFontForTF(childrenLastName, autoCaps: false)
        StaticContentFile.setButtonFont(confirmChangeButton)
        StaticContentFile.setButtonFont(cancelButton, backgroundColorNeeed: false)
       
    
    
    
    
    }

}


//MARK:- KeyBoard delegate methods

extension EditChildNameVC {
    
    @objc fileprivate func keyboardWasShown(_ notification: Notification) {
        
        if let info = (notification as NSNotification).userInfo {
            
            let dictionary = info as NSDictionary
            
            let kbSize = (dictionary.object(forKey: UIKeyboardFrameBeginUserInfoKey)! as AnyObject).cgRectValue.size
            
            self.scrollViewBottomInset = kbSize.height + 10
        }
    }
    
        
        @objc fileprivate func keyboardWillHide(_ notification: Notification) {
            
            self.scrollViewBottomInset = 0
        }
}






